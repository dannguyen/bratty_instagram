require 'slim'
require 'yaml'

Slim::Engine.set_default_options :disable_escape => true

module BrattyPack
  module Routes

    class Base < Sinatra::Application
      set :views, 'app/views'
      set :root, File.expand_path('../../../', __FILE__)

      helpers BrattyPack::Helpers::ApplicationHelper

      module Secrets
        SECRETS_PATH = File.join( Base.root, 'config', 'secrets')
        def self.keys(str)
          File.open(File.join(SECRETS_PATH, "#{str}.yml")) { |y| YAML::load(y) }
        end
      end

      error do
        err = request.env['sinatra.error']
        # if err.class == RestClient::BadRequest
        #   @error = JSON.parse(err.response)
        # end

        erb :err
      end
    end
  end
end
