require 'apis/facebook_api_wrapper'

module BrattyPack
  module Routes
    class Facebook < Base

      get "/facebook" do
        slim :'facebook/index'
      end


      simple_api_endpoint 'users',
          service: 'facebook',
          param_name: :ids,
          presenter_model: 'user'

      simple_api_endpoint 'content_items_for_user',
        service: 'facebook',
        :param_name => :id


    end
  end
end
