require 'apis/instagram_api_wrapper'

module BrattyPack
  module Routes
    class Instagram < Base


      get "/instagram" do
        slim :'instagram/index'
      end

      simple_api_endpoint 'users',
          service: 'instagram',
          param_name: :ids,
          presenter_model: 'user'


    end
  end
end
