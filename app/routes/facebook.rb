require 'apis/facebook_api_wrapper'

module BrattyPack
  module Routes
    class Facebook < Base
      @@facebook_wrapper = FacebookAPIWrapper.new(Secrets.keys('facebook'))

      get "/facebook" do
        slim :'facebook/index'
      end

      get '/facebook/users' do
        names = process_text_input_array(params['ids'].to_s)
        @results = []
        @results += @@facebook_wrapper.fetch(:users, ids)

        slim :'facebook/users'
      end
    end
  end
end
