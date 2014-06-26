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

    def column_names
      @config[:fields].map{|f| f[:name]}
    end

    def parse_into_object(data_obj)
      h = HashWithIndifferentAccess.new

      @config['fields'].each do |field|
        field_name = field['name']
        field_path = field['path']
        if field_path.nil?
          h[field_name] = data_obj[field_name]
        else
          kval = field_path.keys[0]    # :counts
          fpath = field_path[kval]     # { :counts => :media }[:counts]
          obj = data_obj[kval]  # {counts: {media: 100 }}

          while fpath.is_a?(Hash)
            kval = field_path.keys[0]
            fpath = field_path[kval]
            obj = obj[kval]
          end

          h[field_name] = obj[fpath]
        end
      end

      return h
    end


    private



  end
end
