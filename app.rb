require 'rubygems'
require 'bundler/setup'
require 'yaml'
require 'slim'
require './instagram_api_wrapper'

Bundler.require :default
CREDENTIALS = File.open('./keys.yml') { |y| YAML::load(y) }

InstagramAPIWrapper.config_auth!(CREDENTIALS)

class Instagrammy < Sinatra::Base
  enable :sessions
  set :slim, disable_capture: true, disable_escape: true


  def clean_textfield(txt)
    txt.split(/,|\s/).map{|s| s.strip }.reject{|s| s.empty? }
  end


#  set :raise_errors, Proc.new { false }
#  set :show_exceptions, false
  get '/' do
    if !session[:access_token]
      if params[:code]
         session[:access_token] = InstagramAPIWrapper.get_access_token(params[:code])
         InstagramAPIWrapper.set_access_token(session[:access_token]) # TK
      else
        redirect InstagramAPIWrapper.authorize_url
      end
    end

    slim :index
  end

  post '/users' do
    user_ids = clean_textfield(params['users_ids'] || params['ids'])
    @results = InstagramAPIWrapper.fetch(:users, user_ids)

    slim :users
  end

  error do
    err = request.env['sinatra.error']
    # if err.class == RestClient::BadRequest
    #   @error = JSON.parse(err.response)
    # end

    erb :err
  end

  run! if app_file == $0
end
