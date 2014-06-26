require 'apis/youtube_api_wrapper'

module BrattyPack
  module Routes
    class Youtube < Base

      get "/youtube" do
        slim :'youtube/index'
      end

      # get '/youtube/channel_ids' do
      #   names = process_text_input_array(params['names'].to_s)
      #   @results = []
      #   @results += @@youtube_wrapper.fetch(:channel_ids, names)

      #   slim :'youtube/channel_ids'
      # end

      get '/youtube/users' do
        ids = process_text_input_array(params['ids'].to_s)
        @results = init_api_wrapper.fetch(:users, ids)

        @presenter = DataPresenter.new('youtube', 'user')
        @headers = @presenter.column_names
        slim :results_layout, :layout => :layout
      end

    end
  end
end
