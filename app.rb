require 'rubygems'
require 'bundler'
Bundler.require
$: << File.expand_path('../', __FILE__)
$: << File.expand_path('../lib', __FILE__)

require 'sinatra/base'
require 'app/helpers'
require 'app/routes'

module BrattyPack
  class App < Sinatra::Application
    configure do
      disable :method_override
      disable :static
      enable :sessions, :method_override
    end

    use Rack::Deflater
    use BrattyPack::Routes::Instagram


  end
end






# require 'rubygems'
# require 'bundler/setup'
# require 'yaml'
# require 'slim'
# require "sinatra/namespace"

# require './instagram_api_wrapper'

# Bundler.require :default
# Slim::Engine.set_default_options :disable_escape => true


# class BrattyPack < Sinatra::Base
#   register Sinatra::Namespace

#   enable :sessions
#   set :slim, disable_capture: true, disable_escape: true

#   namespace '/instagram' do

#   end



#   error do
#     err = request.env['sinatra.error']
#     # if err.class == RestClient::BadRequest
#     #   @error = JSON.parse(err.response)
#     # end

#     erb :err
#   end



#   run! if app_file == $0
# end
