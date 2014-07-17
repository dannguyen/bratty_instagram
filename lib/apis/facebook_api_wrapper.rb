require 'koala'
require 'apis/api_wrapper'

class FacebookAPIWrapper < APIWrapper
  def initialize(auth_creds)
    @clients = auth_creds.map do |cred|
      token = cred['token']

      Koala::Facebook::API.new(token)
    end
  end

  module Fetchers
    # possible TODOs:
    # comments count, likes count, via summary:
    #    client.get_connections(post['id'], :likes, summary: true, limit: 0).raw_response
    # note that you have to invoke :raw_response, as Koala only returns an Array of
    #  users who liked/commented, and not the summary

    class << self
      # uids is an array of user_ids or names
      def users(user_ids, &blk)
        Array(user_ids).each do |uid|
        foop = Proc.new do |clients|
          client = clients.pop
          client.get_object(uid)
        end

          yield :single, foop, uid
        end
      end


      def content_items_for_user(uid, options = {})
        opts = HashWithIndifferentAccess.new(options)
        item_limit = opts.delete(:item_limit) || 99999
        batch_sleep = opts.delete(:batch_sleep).to_f
        opts[:limit] ||= 25 # this is a limit of posts-per batch, 25 is fine
        # set before/after
        _xbefore = convert_time_param_to_seconds opts.delete('before')
        _xafter = convert_time_param_to_seconds opts.delete('after')
        opts[:until] = ( _xbefore || Time.now.to_i ) - 1 # i.e. minus one second
        opts[:since] = ( _xafter  || Time.parse("2003-01-01") ).to_i # i.e. some arbitrary time before Facebook

        foop = Proc.new do |clients|
          client = clients.pop
          collected_posts = []
          koala = nil # this will be a Koala::Facebook::API::GraphCollection
          while collected_posts.length <= item_limit
            if koala.nil?
              # first iteration
              koala = client.get_connection(uid, :feed, opts)
            else
              # all subsequent iterations uses Koala paging method
              koala = koala.next_page
            end
            # GraphCollection by default can quack like an Array
            posts = koala.to_a
            collected_posts.concat posts

            # now find the "until" time
            np_params = koala.next_page_params
            # this is nil if there are no next pages
            break if np_params.nil?
            # however, we need to manually check that the :since param hasn't been
            # exceeded, since Koala seems to drop it
            break if opts['since'] > np_params[1]['until'].to_i

#            puts "#{collected_posts.count} posts collected. Next-page-until: #{Time.at np_params[1]['until'].to_i}. Sleeping for #{batch_sleep}"
            sleep batch_sleep
          end

          collected_posts
        end

        yield :single, foop, uid
      end



      private
        # returns UTC time in seconds of a timestamp
        # OR, returns nil if invalid
        def convert_time_param_to_seconds(val)
          val = val.to_s
          return nil if val.empty?

          if val =~ /^\d+$/ # i.e, "14929201110", already in seconds
            return val.to_i
          else # e.g. "2009-03-10"
            return Time.parse(val).to_i
          end
        end
    end
  end


end
