require 'apis/instagram_api_wrapper'

module BrattyPack
  module Routes

    class Instagram < Base
      INSTAGRAM_CREDENTIALS = Secrets.keys('instagram')
      InstagramAPIWrapper.config_auth!(INSTAGRAM_CREDENTIALS)


      get "/instagram" do
        slim :'instagram/index'
      end

      get '/instagram/users' do
        user_ids = clean_textfield(params['users_ids'] || params['ids'])
        @results = InstagramAPIWrapper.fetch(:users, user_ids)

        slim :'instagram/users'
      end
    end
  end
end



  # currently deprecated until good flow is set
  # get '/web_auth' do
  #   if params[:code]
  #      session[:access_token] = InstagramAPIWrapper.get_access_token(params[:code])
  #      InstagramAPIWrapper.set_access_token(session[:access_token]) # TK
  #   else
  #     redirect InstagramAPIWrapper.authorize_url
  #   end
  # end
