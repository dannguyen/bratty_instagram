require 'apis/twitter_api_wrapper'

module BrattyPack
  module Routes
    class Twitter < Base
      TWITTER_CREDENTIALS = Secrets.keys('twitter')
      @@twitter_wrapper = TwitterAPIWrapper.new(TWITTER_CREDENTIALS)


      get '/twitter/users' do
        user_names = process_text_input_array(params['user_names'].to_s)
        # conver to real Numbers so that Twitter Client will search by userid, not screen_name
        user_ids = process_text_input_array(params['user_ids'].to_s).map{|u| u.to_i}

        @results = @@twitter_wrapper.fetch(:users, user_names + user_ids)

        slim :'twitter/users'
      end
    end
  end
end
