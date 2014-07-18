require 'apis/instagram_api_wrapper'

module BrattyPack
  module Routes
    class Instagram < Base

      # get "/instagram" do
      #   slim :'instagram/index'
      # end

      # /api/youtube/users
      simple_api_endpoint 'users', service: 'instagram', :presenter_model => :user do |options|
        opts = options.dup
        user_ids = process_text_input_array( opts.delete('ids') )

        init_api_wrapper.fetch('users', user_ids, opts  )
      end

      simple_api_endpoint 'content_items_for_user', service: 'instagram', :presenter_model => :media do |options|
        opts = options.dup
        user_id = opts.delete('id')

        init_api_wrapper.fetch('content_items_for_user', user_id, opts  )
      end

    end
  end
end
