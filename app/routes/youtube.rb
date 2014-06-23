require 'apis/youtube_api_wrapper'

module BrattyPack
  module Routes
    class Youtube < Base
      @@youtube_wrapper = YoutubeAPIWrapper.new(Secrets.keys('youtube'))

      get "/youtube" do
        slim :'youtube/index'
      end

      get '/youtube/channel_ids' do
        names = process_text_input_array(params['names'].to_s)
        @results = []
        @results += @@youtube_wrapper.fetch(:channel_ids, names)

        slim :'youtube/channel_ids'
      end
    end
  end
end
