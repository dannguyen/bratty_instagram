require 'instagram'
require 'apis/api_wrapper'

class InstagramAPIWrapper < APIWrapper
  INSTAGRAM_ID_PATTERN = /^\d{3,}$/

  def initialize(auth_opts)
    @clients = auth_opts.map do |a|
      client = Instagram::Client.new
      client.client_id = a['id']
      client.access_token = a['access_token']

      client
    end
    # new Keys format TK
  end


  module Fetchers
    class << self
      # uids is an array of user_ids or names
      def users(uids, &blk)
        Array(uids).each do |user_id|
          foop = Proc.new do |clients|
            client = clients.pop
            uid = translate_to_user_id(client, user_id)

            client.user(uid)
          end

          yield :single, foop, user_id
        end
      end

      # NOTE: the :before and :after refer to the MIN_TIMESTAMP and MAX_TIMESTAMP
      # Instagram's API does allow for min_id/max_id to be used, but we will ignore
      # that for the time being
      def content_items_for_user(user_id, options = {})
        opts = HashWithIndifferentAccess.new(options)
        item_limit = opts.delete(:item_limit) || 10000
        batch_sleep = opts.delete(:batch_sleep).to_f

        ## setting before and after
        _xbefore = convert_time_param_to_seconds( opts.delete('before') )
        _xafter = convert_time_param_to_seconds( opts.delete('after') )
        opts[:max_timestamp] = ( _xbefore || Time.now.to_i ) - 1 # i.e. minus one second
        opts[:min_timestamp] = ( _xafter  || Time.parse("2003-01-01") ).to_i # i.e. some arbitrary time before Facebook
        opts[:count] ||= 25

        collected_media = []
        foop = Proc.new do |clients|
          client = clients.pop
          # first, get the proper user_id
          uid = translate_to_user_id(client, user_id)
          nxt_step = HashWithIndifferentAccess.new
          while collected_media.length <= item_limit
            # The call to Instagram's API
            resp = client.user_recent_media(uid, opts.merge(nxt_step))
            media_items = resp.to_a
            collected_media.concat media_items
            # Instagram response object has a pagination method
            # {"next_url"=>
            #   "https://api.instagram.com/v1/users/999/media/recent?access_token=XXX&max_id=1000_9999",
            #  "next_max_id"=>"1000_9999"}
            p = resp.pagination
            break if p.empty?
            # pagination always returns next_max_id
            # so we use that, and that will be the limiting factor even if
            # max_timestamp was originally set
            nxt_step[:max_id] = p.next_max_id
            puts "#{collected_media.count} posts collected. Next-max-id: #{nxt_step[:max_id]}. Sleeping for #{batch_sleep}"
            sleep batch_sleep
          end

          collected_media
        end

        yield :single, foop, user_id
      end


      private


        # val is a String
        #
        # returns actual instagram user ids, mapped to Hash
        # {'snoopdogg' => 8273372, '9349438' => 9349438, 'https://instagram.com/danwinny' => 7123452 }
        def translate_to_user_id(client, val)
          u = val.strip

          if u =~ INSTAGRAM_ID_PATTERN
            return u
          else
            # extract user name as part of a hash
            uname = u[/(?<=instagram\.com\/)\w+/] || u
            user = _search_for_user_from_username(client, uname)

            return user['id']
          end
        end

        # Return a Instagram::User ID from a uname like 'snoopdogg'
        def _search_for_user_from_username(client, uname)
          arr = client.user_search(uname)
          user = arr.find{|h| h['username'].downcase == uname.downcase}
          raise InstagramUsernameDoesntExist, "Could not find user #{uname}" if user.nil?

          return user
        end

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

        ### private
    end
  end


end


class InstagramApiWrapperError < StandardError; end
class InstagramUsernameDoesntExist < InstagramApiWrapperError; end
