require 'slim'
require 'yaml'



Slim::Engine.set_default_options :disable_escape => false, :disable_capture => true

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

      class << self
        # (should this be in the controller?)
        def init_api_wrapper(service_name=nil)
          if service_name.nil?
            service_name = self.name.split('::')[-1]
          end
          wrapper_klass = Kernel.const_get(:"#{service_name.capitalize}APIWrapper")
          # init with secrets
          wrapper_klass.new(Secrets.keys(service_name.downcase))
        end
      end

      private
        def init_api_wrapper
          self.class.init_api_wrapper
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
