require 'apis/twitter_api_wrapper'

module BrattyPack
  module Routes
    class Twitter < Base
      TWITTER_CREDENTIALS = Secrets.keys('twitter')
      @@twitter_wrapper = TwitterAPIWrapper.new(TWITTER_CREDENTIALS)

      get "/twitter" do
        slim :'twitter/index'
      end

      get '/twitter/users' do
        names = process_text_input_array(params['screen_names'].to_s)
        # conver to real Numbers so that Twitter Client will search by userid, not screen_name
        ids = process_text_input_array(params['ids'].to_s).map{|u| u.to_i}

        @results = []

        @results += @@twitter_wrapper.fetch(:users, ids)
        @results += @@twitter_wrapper.fetch(:users, names)

        slim :results_layout, :layout => :layout do
          slim :'twitter/users'
        end
      end
    end
  end
end
