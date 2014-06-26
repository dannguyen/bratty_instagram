require 'apis/twitter_api_wrapper'

module BrattyPack
  module Routes
    class Twitter < Base

      get "/twitter" do
        slim :'twitter/index'
      end

      simple_api_endpoint 'users',
                    service: 'twitter',
                    param_name: [:ids, :screen_names],
                    presenter_model: 'user' do |_params|

        wrapper = init_api_wrapper
        user_ids = process_text_input_array(_params['ids'].to_s).map{|u| u.to_i}
        screen_names = process_text_input_array(_params['screen_names'].to_s)

        results = []
        results += wrapper.fetch(:users, user_ids)
        results += wrapper.fetch(:users, screen_names)

        results
      end


      # get '/twitter/users' do
      #   names = process_text_input_array(params['screen_names'].to_s)
      #   # conver to real Numbers so that Twitter Client will search by userid, not screen_name
      #   ids = process_text_input_array(params['ids'].to_s).map{|u| u.to_i}

      #   wrapper = init_api_wrapper
      #   @results = []
      #   @results += wrapper.fetch(:users, ids)
      #   @results += wrapper.fetch(:users, names)

      #   @presenter = DataPresenter.new('twitter', 'user')
      #   slim :results_layout, :layout => :layout

      # end
    end
  end
end
