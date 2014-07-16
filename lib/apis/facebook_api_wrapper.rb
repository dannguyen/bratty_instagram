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
          foop = Proc.new do |client|
            client.get_object(uid)
          end

          yield :single, foop, uid
        end
      end

      def content_items_for_user(uid, options = {})
        f_opts = HashWithIndifferentAccess.new(options)
        f_opts[:limit] ||= 25
        # set before/after
        _xbefore = convert_time_param_to_seconds f_opts.delete('before')
        _xafter = convert_time_param_to_seconds f_opts.delete('after')
        f_opts[:until] = ( _xbefore || Time.now.to_i ) - 1 # i.e. minus one second
        f_opts[:since] = _xafter || Time.parse("2003-01-01") # i.e. some arbitrary time before Facebook

        foop = Proc.new do |client|
          # by default, get 25 posts
          client.get_connection(uid, :feed, f_opts)
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
            return Time.parse(val)
          end
        end
    end
  end


end
