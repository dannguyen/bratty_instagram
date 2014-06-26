require 'apis/facebook_api_wrapper'

module BrattyPack
  module Routes
    class Facebook < Base

      get "/facebook" do
        slim :'facebook/index'
      end

      get '/facebook/users' do
        ids = process_text_input_array(params['ids'].to_s)
        @results = []
        @results += init_api_wrapper.fetch(:users, ids)

        @presenter = DataPresenter.new('facebook', 'user')
        @headers = @presenter.column_names
        slim :results_layout, :layout => :layout
      end
    end
  end
end
