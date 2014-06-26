module BrattyPack
  class DataPresenter
    CONFIGS_DIR = File.expand_path("../models", __FILE__)
    class << self
      def load_config(s, m_name)
        h = YAML.load_file(File.join(CONFIGS_DIR, "#{s}.yml"))[m_name]

        return HashWithIndifferentAccess.new(h)
      end
    end

    attr_reader :service_name, :model_name, :config
    def initialize(_service_name, _model_name)
      @service_name = _service_name.to_s.downcase
      @model_name = _model_name.to_s.downcase
      @config = self.class.load_config(@service_name, @model_name)
    end

    def readable_column_names
      @config[:fields].map{ |f| f[:name].gsub('_', ' ') }
    end

    def columns
      @config[:fields].map{|f| f[:name]}
    end

    def parse_into_object(data_obj)
      h = HashWithIndifferentAccess.new

      @config['fields'].each do |field|
        field_name = field['name']
        f_nested = field['nested']

        if f_nested.nil?
          h[field_name] = data_obj[field_name]
        else
          obj = data_obj
          kval = f_nested.keys[0]    # :counts
          fn = f_nested[kval]     # { :counts => :media }[:counts]

          while obj.is_a?(Hash)
            obj = obj[kval]
            break unless fn.is_a?(Hash)

            kval = fn.keys[0]
            fn = fn[kval]
          end

          h[field_name] = obj.nil? ? nil : obj[fn]
        end
      end

      return h
    end


    private



  end
end
