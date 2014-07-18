require 'apis/twitter_api_wrapper'

module BrattyPack
  module Routes
    class Twitter < Base

      simple_api_endpoint 'users', service: 'twitter', :presenter_model => :user do |options|
        opts = options.dup
        user_ids = process_text_input_array(opts.delete('ids').to_s).map{|u| u.to_i}
        screen_names = process_text_input_array(opts.delete('screen_names').to_s)

        results = []
        wrapper = init_api_wrapper
        results += wrapper.fetch(:users, user_ids, opts)
        results += wrapper.fetch(:users, screen_names, opts)

        results
      end

      simple_api_endpoint 'content_items_for_user', service: 'twitter', :presenter_model => :tweet do |options|
        opts = options.dup
        user_id = opts.delete('id')

        init_api_wrapper.fetch('content_items_for_user', user_id, opts  )
      end


      # simple_api_endpoint 'content_items',
      #               service: 'twitter',
      #               param_name: :ids,
      #               presenter_model: 'tweet'




    end
  end
end
