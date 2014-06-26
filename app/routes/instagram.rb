require 'apis/instagram_api_wrapper'

module BrattyPack
  module Routes
    class Instagram < Base
      INSTAGRAM_CREDENTIALS = Secrets.keys('instagram')
      @@instagram_wrapper = InstagramAPIWrapper.new(INSTAGRAM_CREDENTIALS)

      get "/instagram" do
        slim :'instagram/index'
      end

      get '/instagram/users' do
        user_ids = process_text_input_array(params['users_ids'] || params['ids'])
        @results = @@instagram_wrapper.fetch(:users, user_ids)

        # note that the :body of each
        @results = @results.map{|o| DataWrapper.new('instagram', 'user', o.body)}
        @headers = @results.first.column_names

        slim :results_layout, :layout => :layout do
          slim :'instagram/users'
        end
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
