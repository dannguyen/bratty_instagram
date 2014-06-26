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
    end
  end
end
