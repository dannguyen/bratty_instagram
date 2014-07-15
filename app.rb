require 'rubygems'
require 'bundler'
Bundler.require
$: << File.expand_path('../', __FILE__)
$: << File.expand_path('../lib', __FILE__)

require 'sinatra/base'
require 'app/helpers'
require 'app/routes'

require 'i18n'
I18n.config.enforce_available_locales = false

module BrattyPack
  class App < Sinatra::Application
    configure do
      disable :static
      enable :sessions, :method_override
    end


    use Rack::Deflater
    use BrattyPack::Routes::Facebook
    use BrattyPack::Routes::Instagram
    use BrattyPack::Routes::Twitter
    use BrattyPack::Routes::Youtube


    set :views, 'app/views'
    get '/' do
      slim :index
    end


  end
end






