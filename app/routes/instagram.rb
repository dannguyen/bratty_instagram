require 'apis/instagram_api_wrapper'

module BrattyPack
  module Routes
    class Instagram < Base


      get "/instagram" do
        slim :'instagram/index'
      end

      get '/instagram/users' do
        user_ids = process_text_input_array(params['users_ids'] || params['ids'])
        @results = init_api_wrapper.fetch(:users, user_ids)
        @presenter = DataPresenter.new('instagram', 'user')
        @headers = @presenter.column_names
        slim :results_layout, :layout => :layout
      end


      module ResultDataObjects
        class << self
          def user(obj)
          end
        end
      end

    end
  end
end
