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

    @google_api = @clients[0].discovered_api(GOOGLE_API_SERVICE_NAME, GOOGLE_API_SERVICE_VERSION)
  end

end



