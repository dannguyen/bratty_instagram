require 'apis/twitter_api_wrapper'

module BrattyPack
  module Routes
    class Twitter < Base

      simple_api_endpoint 'users',
                    service: 'twitter',
                    param_name: [:ids, :screen_names],
                    presenter_model: 'user' do |_params|

        wrapper = init_api_wrapper
        user_ids = process_text_input_array(_params['ids'].to_s).map{|u| u.to_i}
        screen_names = process_text_input_array(_params['screen_names'].to_s)

        results = []
        results += wrapper.fetch(:users, user_ids)
        results += wrapper.fetch(:users, screen_names)

        results
      end


      simple_api_endpoint 'content_items',
                    service: 'twitter',
                    param_name: :ids,
                    presenter_model: 'tweet'


      simple_api_endpoint 'content_items_for_user',
                    service: 'twitter' do |_params|
                    # param_name: [:id],
                    # presenter_model: 'tweet'

        wrapper = init_api_wrapper
        uid = _params[:id]

        results = wrapper.fetch(:content_items_for_user, uid)
      end




    end
  end
end
