require 'apis/facebook_api_wrapper'

module BrattyPack
  module Routes
    class Facebook < Base

      get "/facebook" do
        slim :'facebook/index'
      end

      # /api/youtube/users
      simple_api_endpoint 'users', service: 'facebook', :presenter_model => :user do |options|
        opts = options.dup
        user_ids = process_text_input_array( opts.delete('ids') )

        init_api_wrapper.fetch('users', user_ids, opts  )
      end

      simple_api_endpoint 'content_items_for_user', service: 'facebook', :presenter_model => :post do |options|
        opts = options.dup
        user_id = opts.delete('id')

        init_api_wrapper.fetch('content_items_for_user', user_id, opts  )
      end




    end
  end
end
