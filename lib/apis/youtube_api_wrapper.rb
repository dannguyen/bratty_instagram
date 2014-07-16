require 'google/api_client'
require 'apis/api_wrapper'

class YoutubeAPIWrapper < APIWrapper


  GOOGLE_API_SERVICE_NAME = 'youtube'
  GOOGLE_API_SERVICE_VERSION = 'v3'
  YOUTUBE_CHANNEL_ID_PATTERN = /^UC[\w\-_]{22,}$/
  YOUTUBE_MAX_BATCH_IDS_SIZE = 50
  DEFAULT_DATA_CHANNEL_PARTS = %w(id snippet contentDetails status statistics)
  DEFAULT_DATA_VIDEO_PARTS = %w(id snippet contentDetails status statistics)
  attr_reader :google_api

 def initialize(auth_keys)
    arr = auth_keys.is_a?(Hash) ? [auth_keys] : Array(auth_keys)

    # there's actually only one client
    @clients = [
      Google::APIClient.new(arr.first)
    ]
  end

 module Fetchers
    class << self

      #   # deprecate
      # def channel_ids(unames)
      #   Array(unames).each do |uname|
      #     fetch_proc = Proc.new do |client|
      #       get_channel_id_from_username(client, uname)
      #     end

      #     yield :single, fetch_proc, uname
      #   end
      # end


      def users(ux)
        uids = Array(ux)
        # first, collect info for entries that are channel IDs
        all_cids = uids.select{|u| is_youtube_id?(u) }

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

      # uid could be username or channel ID...ideally
      # it should be channel ID
      def content_items_for_user(uid, options={})
        foop = Proc.new do |client|
          if !is_youtube_id?(uid)
            # do an extra get for the channel and its canonical id
            channel = get_channel_from_username(client, uid)
            uid = channel['id']
          end
          list_id = derive_playlist_id_from_channel_id(uid)

          get_video_list_from_playlist_id(client, list_id)
        end

        yield :single, foop, uid
      end




      private

        def is_youtube_id?(u)
          u =~ YoutubeAPIWrapper::YOUTUBE_CHANNEL_ID_PATTERN
        end

        # u is an actual Youtube unique ID,e.g. UCjSrVD08nsyPDCNRjqSV7yA
        def derive_playlist_id_from_channel_id(u)
          if !is_youtube_id?(u)
            raise StandardError, "Cannot derive playlist ID from #{u}; provide an official youtube unique identifier"
          else
            return u.sub(/^UC/, 'UU')
          end
        end

        def get_channels_from_channel_ids(client, uids)
          items = get_channel(client, { id: Array(uids).join(',') })
        end

        # by specifying the username, Youtube only lets us get one channel at a time
        # this always returns one channel, as opposed to multiple channels
        def get_channel_from_username(client, uname)
          items = get_channel(client, {forUsername: uname})

          if( item = items[0] )
            return item
          else
            raise YoutubeUsernameNotFound, "Could not find channel id with username: #{uname}"
          end
        end

        def get_channel_video_list(client, options)
          # todo: wrap around get_channel and get_video_listing
        end

        # TODO, list all videos
        def get_video_list_from_playlist_id(client, list_id, options={})
          opts = HashWithIndifferentAccess.new(options)
          opts[:playlistId] = list_id
          opts[:part] ||= 'contentDetails,snippet'
          opts[:maxResults] ||= YOUTUBE_MAX_BATCH_IDS_SIZE
          api_obj = init_api_list_call_object(client, 'playlist_items')
          resp = client.execute!(api_obj, opts)

          items = extract_and_parse_items_from_response(resp)
        end

        def get_channel(client, options)
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
