require 'apis/twitter_api_wrapper'

module BrattyPack
  module Routes
    class Twitter < Base

      get "/twitter" do
        slim :'twitter/index'
      end

      get '/twitter/users' do
        names = process_text_input_array(params['screen_names'].to_s)
        # conver to real Numbers so that Twitter Client will search by userid, not screen_name
        ids = process_text_input_array(params['ids'].to_s).map{|u| u.to_i}

        wrapper = init_api_wrapper
        @results = []
        @results += wrapper.fetch(:users, ids)
        @results += wrapper.fetch(:users, names)

        @presenter = DataPresenter.new('twitter', 'user')
        @headers = @presenter.column_names
        slim :results_layout, :layout => :layout

      end
    end
  end
end
