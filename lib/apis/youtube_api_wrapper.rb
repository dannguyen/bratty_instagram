require 'google/api_client'
require 'apis/api_wrapper'

class YoutubeAPIWrapper < APIWrapper


  GOOGLE_API_SERVICE_NAME = 'youtube'
  GOOGLE_API_SERVICE_VERSION = 'v3'
  YOUTUBE_CHANNEL_ID_PATTERN = /^UC[\w\-_]{22,}$/
  YOUTUBE_MAX_BATCH_IDS_SIZE = 50
  DEFAULT_DATA_CHANNEL_PARTS = %w(id snippet contentDetails status statistics)
  attr_reader :google_api

 def initialize(auth_keys)
    arr = auth_keys.is_a?(Hash) ? [auth_keys] : Array(auth_keys)

    # there's actually only one client
    @clients = [
      Google::APIClient.new(arr.first)
    ]

#    @google_api = @clients[0].discovered_api(GOOGLE_API_SERVICE_NAME, GOOGLE_API_SERVICE_VERSION)
  end

 module Fetchers
    class << self

      def channel_ids(unames)
        # deprecate
        Array(unames).each do |uname|
          fetch_proc = Proc.new do |client|
            get_channel_id_from_username(client, uname)
          end

          yield :single, fetch_proc, uname
        end
      end


      def users(ux)
        uids = Array(ux)
        # first, collect info for entries that are channel IDs
        all_cids = uids.select{|u| u =~ YoutubeAPIWrapper::YOUTUBE_CHANNEL_ID_PATTERN }

        Array(all_cids).each_slice(YoutubeAPIWrapper::YOUTUBE_MAX_BATCH_IDS_SIZE) do |cids|
          foop = Proc.new do |client|
            items =  get_channels_from_channel_ids(client, cids)

            glob_users(items, cids)
          end

          yield :batch, foop, cids
        end


        # now collect info for entries that are usernames, not channel IDs
        unames = uids - all_cids
        unames.each do |uname|
          foop = Proc.new do |client|
            get_channel_from_username(client, uname)
          end

          yield :single, foop, uname
        end
      end




      private
        def get_channels_from_channel_ids(client, uids)
          items = get_channel_listing(client, { id: Array(uids).join(',') })
        end

        def get_channel_from_username(client, uname)
          items = get_channel_listing(client, {forUsername: uname})

          if( item = items[0] )
            return item
          else
            raise YoutubeUsernameNotFound, "Could not find channel id with username: #{uname}"
          end
        end


        def get_channel_listing(client, options)
          opts = HashWithIndifferentAccess.new(options)
          opts['part'] ||= YoutubeAPIWrapper::DEFAULT_DATA_CHANNEL_PARTS.join(',')
          opts['maxResults'] ||= YoutubeAPIWrapper::YOUTUBE_MAX_BATCH_IDS_SIZE
          api_obj = init_api_list_call_object(client, 'channels')
          resp = client.execute!(api_obj, opts )

          items = extract_and_parse_items_from_response(resp)
        end

       def glob_users(users, ukeys)
          users_arr = users.map{|u| HashWithIndifferentAccess.new(u.to_h) }
          ukeys.inject({}) do |h, key|
            uhsh = users_arr.find{|u| u[:id] == key }
            h[key] = uhsh.nil? ? YoutubeChannelIDNotFound.new("Channel ID: #{key} not found") : uhsh

            h
          end
        end

        # fooname is a string, e.g. 'channels'
        # returns: #<Google::APIClient::Method:0x1111 ID:youtube.fooname.list>

        def init_api_list_call_object(client, fooname)
          api = client.discovered_api( YoutubeAPIWrapper::GOOGLE_API_SERVICE_NAME, YoutubeAPIWrapper::GOOGLE_API_SERVICE_VERSION)

          return api.send(fooname).list
        end

        # returns an array
        def extract_and_parse_items_from_response(resp)
          obj = JSON.parse resp.response.body

          return Array(obj['items'])
        end

    end
  end
end






class YoutubeApiWrapperError < StandardError; end
class YoutubeUsernameNotFound < YoutubeApiWrapperError; end
class YoutubeChannelIDNotFound < YoutubeApiWrapperError; end
