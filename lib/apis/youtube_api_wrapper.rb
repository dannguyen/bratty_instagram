require 'google/api_client'
require 'apis/api_wrapper'

class YoutubeAPIWrapper < APIWrapper


  GOOGLE_API_SERVICE_NAME = 'youtube'
  GOOGLE_API_SERVICE_VERSION = 'v3'
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
        Array(unames).each do |uname|
          fetch_proc = Proc.new do |client|
            api = client.discovered_api(GOOGLE_API_SERVICE_NAME, GOOGLE_API_SERVICE_VERSION)
            get_channel_id_from_username(client, api, uname)
          end

          yield :single, fetch_proc, uname
        end
      end


      private
        def get_channel_id_from_username(client, api, uname)
          api_obj = init_api_list_call_object(api, 'channels')
          opts = {forUsername: uname, part: 'id'}
          resp = client.execute!(api_obj, opts)
          items = extract_and_parse_items_from_response(resp)

          if(item = items[0])
            return HashWithIndifferentAccess.new({id: item['id']})
          else
            raise YoutubeChannelIdNotFound, "Could not find channel id for #{uname}"
          end
        end


        def init_api_list_call_object(api, fooname)
          api.send(fooname).list
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
class YoutubeChannelIdNotFound < YoutubeApiWrapperError; end

