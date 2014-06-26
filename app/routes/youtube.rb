require 'apis/youtube_api_wrapper'

module BrattyPack
  module Routes
    class Youtube < Base

      get "/youtube" do
        slim :'youtube/index'
      end


      # /api/youtube/users
      simple_api_endpoint 'users',
          service: 'youtube',
          param_name: :ids,
          presenter_model: 'user'

      # get '/youtube/users' do
      #   ids = process_text_input_array(params['ids'].to_s)
      #   @results = init_api_wrapper.fetch(:users, ids)

      #   @presenter = DataPresenter.new('youtube', 'user')
      #   slim :results_layout, :layout => :layout
      # end

    end
  end
end
