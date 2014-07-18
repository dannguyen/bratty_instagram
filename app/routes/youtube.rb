require 'apis/youtube_api_wrapper'

module BrattyPack
  module Routes
    class Youtube < Base

      # get "/youtube" do
      #   slim :'youtube/index'
      # end


      # /api/youtube/users
      simple_api_endpoint 'users', service: 'youtube', :presenter_model => :user do |options|
        opts = options.dup
        user_ids = process_text_input_array( opts.delete('ids') )

        init_api_wrapper.fetch('users', user_ids, opts  )
      end

      simple_api_endpoint 'content_items_for_user', service: 'youtube' do |options|
        opts = options.dup
        user_id = opts.delete('id')

        init_api_wrapper.fetch('content_items_for_user', user_id, opts  )
      end


      # get '/youtube/users' do
      #   ids = process_text_input_array(params['ids'].to_s)
      #   @results = init_api_wrapper.fetch(:users, ids)

      #   @presenter = DataPresenter.new('youtube', 'user')
      #   slim :results_layout, :layout => :layout
      # end

    end
  end
end
