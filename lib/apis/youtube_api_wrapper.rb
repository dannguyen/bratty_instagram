require 'google/api_client'
require 'apis/api_wrapper'

## This Youtube has more private methods than the other wrappers, (e.g. get_channel_from_username)
#  but that's because there's a lot of Google-API specific conventions to follow


class YoutubeAPIWrapper < APIWrapper

  GOOGLE_API_SERVICE_NAME = 'youtube'
  GOOGLE_API_SERVICE_VERSION = 'v3'
  YOUTUBE_CHANNEL_ID_PATTERN = /^UC[\w\-_]{22,}$/
  YOUTUBE_MAX_BATCH_IDS_SIZE = 50
  DEFAULT_DATA_CHANNEL_PARTS = %w(id snippet contentDetails status statistics).join(',')
  DEFAULT_DATA_VIDEO_PARTS = %w(id snippet contentDetails status statistics).join(',')
  attr_reader :google_api

 def initialize(auth_keys)
    arr = auth_keys.is_a?(Hash) ? [auth_keys] : Array(auth_keys)
    @clients = arr.map{ |keys| Google::APIClient.new(keys) }
  end

 module Fetchers
    class << self

      def users(ux, options = {})
        opts = HashWithIndifferentAccess.new(options)  # nothing needed here, but accept it anyway
        uids = Array(ux)
        # first, collect info for entries that are channel IDs
        all_cids = uids.select{|u| is_youtube_id?(u) }

        Array(all_cids).each_slice(YoutubeAPIWrapper::YOUTUBE_MAX_BATCH_IDS_SIZE) do |cids|
          foop = Proc.new do |clients|
            client = clients.pop
            resp =  get_channels_from_channel_ids(client, cids)
            channels = extract_items_from_response(resp) # remove Google API metaheaders
            glob_users(channels, cids)
          end

          yield :batch, foop, cids
        end

        # now collect info for entries that are usernames, not channel IDs, and do that fetch
        unames = uids - all_cids
        unames.each do |uname|
          foop = Proc.new do |clients|
            client = clients.pop
            # no need to remove metaheaders, as that's done inside the method
            channel = get_channel_from_username(client, uname)
          end

          yield :single, foop, uname
        end
      end


      # user_id could be username or channel ID...ideally
      # it should be channel ID
      def content_items_for_user(user_id, options = {})
        opts = HashWithIndifferentAccess.new(options)
        item_limit  = (opts.delete(:item_limit) || 10000).to_i
        batch_sleep = opts.delete(:batch_sleep).to_f
        foop = Proc.new do |clients|
          client = clients.pop
          if !is_youtube_id?(user_id)
            # do an extra get for the channel and its canonical id
            channel = get_channel_from_username(client, user_id)
            user_id = channel['id']
          end
          list_id = derive_playlist_id_from_channel_id(user_id)

          # now we make multiple iterations to get the entire list
          collected_videos = []
          token_hsh = {}

          while collected_videos.length < item_limit
            resp = get_video_list_from_playlist_id(client, list_id, token_hsh)
            # temp array
            _vids = extract_items_from_response(resp).map{ |v| v['contentDetails']['videoId'] }
            # now run the method to get all the video details
            collected_videos.concat extract_items_from_response( get_video_details(client, _vids) )
            # now see if there's a next page token
            token_hsh['pageToken'] = extract_next_page_token(resp)
            break if token_hsh['pageToken'].nil?

            sleep batch_sleep
          end

          collected_videos
        end

        yield :single, foop, user_id
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


        # by specifying the username, Youtube only lets us get one channel at a time
        # this always returns one channel, as opposed to multiple channels

        def get_channel_from_username(client, uname)
          resp = get_channel(client, {forUsername: uname})
          channels = extract_items_from_response(resp)
          if( channels = channels[0] )
            return channels
          else
            raise YoutubeUsernameNotFound, "Could not find channel id with username: #{uname}"
          end
        end

        # returns a Youtube standard response, in which all
        # the items simply have:
        # "contentDetails" => { "videoId" => "ZZsTQwPW6x4" }
        def get_video_list_from_playlist_id(client, list_id, options={})
          opts = HashWithIndifferentAccess.new(options)
          opts[:playlistId] = list_id
          opts[:part] ||= 'contentDetails'
          opts[:maxResults] ||= YOUTUBE_MAX_BATCH_IDS_SIZE
          api_obj = init_api_list_call_object(client, 'playlist_items')

          resp = client.execute!(api_obj, opts)
        end

        def get_video_details(client, v_ids, options = {})
          opts = HashWithIndifferentAccess.new(options)
          opts['part'] ||= YoutubeAPIWrapper::DEFAULT_DATA_VIDEO_PARTS
          opts['id'] = Array(v_ids).join(',')
          api_obj = init_api_list_call_object(client, 'videos')

          resp = client.execute!( api_obj, opts )
        end

        def get_channel(client, options)
          opts = HashWithIndifferentAccess.new(options)
          opts['part'] ||= YoutubeAPIWrapper::DEFAULT_DATA_CHANNEL_PARTS
          opts['maxResults'] ||= YoutubeAPIWrapper::YOUTUBE_MAX_BATCH_IDS_SIZE
          api_obj = init_api_list_call_object(client, 'channels')

          resp = client.execute!( api_obj, opts )
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

        # resp is a Google::APIClient::Result
        # returns an array
        def extract_items_from_response(resp)
          obj = JSON.parse resp.response.body
          return Array(obj['items'])
        end


        # resp is a Google::APIClient::Result
        def extract_next_page_token(resp)
          obj = JSON.parse resp.response.body
          return obj['nextPageToken']
        end

    end
  end
end






class YoutubeApiWrapperError < StandardError; end
class YoutubeUsernameNotFound < YoutubeApiWrapperError; end
class YoutubeChannelIDNotFound < YoutubeApiWrapperError; end
