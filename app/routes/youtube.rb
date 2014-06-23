require 'apis/youtube_api_wrapper'

module BrattyPack
  module Routes
    class Youtube < Base
      @@youtube_wrapper = YoutubeAPIWrapper.new(Secrets.keys('youtube'))

      get "/youtube" do
        slim :'youtube/index'
      end

      get '/youtube/users' do
        names = process_text_input_array(params['ids'].to_s)
        @results = []
        @results += @@youtube_wrapper.fetch(:users, ids)

        slim :'youtube/users'
      end
    end
  end
end
