require 'slim'
require 'yaml'
require 'sinatra/json'
require 'csv'


Slim::Engine.set_default_options :disable_escape => false, :disable_capture => true

module BrattyPack
  module Routes
    class Base < Sinatra::Application
      set :views, 'app/views'
      set :root, File.expand_path('../../../', __FILE__)

      helpers BrattyPack::Helpers::ApplicationHelper
      helpers Sinatra::JSON

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

        # Repeated from the Helper, for accessibility in simple_api_endpoint
        def process_text_input_array(tf)
          txt = tf.to_s.strip # first, strip out newlines

          (txt =~ /\n/ ? txt.split("\n") : txt.split(',')).
            map{|s| s.strip }.reject{|s| s.empty? }
        end

      # for some conventions
      # e.g. simple_api_endpoint 'users',
      #     service: 'youtube',
      #     param_name: :ids,
      #     presenter_model: 'user'
        def simple_api_endpoint(endpoint_name, options={})
          opts = HashWithIndifferentAccess.new(options)

          http_method = opts[:http_method] || :get
          service_name = opts[:service]
          param_name = opts[:param_name]
          presenter_model_name = opts[:presenter_model]

          self.send(http_method, "/api/#{service_name}/#{endpoint_name}") do
            if block_given?
              @results = yield params
            else
              input_vals = process_text_input_array(params[param_name.to_sym])
              @results = init_api_wrapper.fetch(endpoint_name, input_vals)
            end

            @presenter = DataPresenter.new(service_name, presenter_model_name)
            slim :results_layout, :layout => :layout
          end

          # TK: dry this up
          #### To CSV
          # each field will be a :formatted_value
          #  just as if it were a HTML response. Both CSV and HTML provide simplified
          #  abstractions of the data object

          self.send(http_method, "/api/#{service_name}/#{endpoint_name}.csv") do
            if block_given?
              @results = yield params
            else
              input_vals = process_text_input_array(params[param_name.to_sym])
              @results = init_api_wrapper.fetch(endpoint_name, input_vals)
            end

            @presenter = DataPresenter.new(service_name, presenter_model_name)

            content_type 'application/csv'
            CSV.generate(headers: true) do |csv|
              headers = @presenter.columns
              csv << headers
              @results.each do |result|
                if result.success?
                  p_obj = @presenter.create_presentable_object(result.body)

                  csv << headers.map{ |col_name| p_obj[col_name][:value] }
                else
                  csv << [result.params.to_s, result.message ]
                end
              end
            end

          end


          ### to JSON, TK: DRY it up
          # Json doesn't require a presenter, it just sends the straight results
          self.send(http_method, "/api/#{service_name}/#{endpoint_name}.json") do
            if block_given?
              @results = yield params
            else
              input_vals = process_text_input_array(params[param_name.to_sym])
              @results = init_api_wrapper.fetch(endpoint_name, input_vals)
            end

            json(@results)
          end



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
