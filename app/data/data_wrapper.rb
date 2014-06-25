module BrattyPack
  class DataWrapper
    CONFIGS_DIR = File.expand_path("../models", __FILE__)
    class << self
      attr_reader :wrapper_configs


      def load_config(s, m_name)
        @wrapper_configs ||= HashWithIndifferentAccess.new{|h, k| h[k] = {}}

        @wrapper_configs[s][m_name] ||= YAML.load_file(File.join(CONFIGS_DIR, "#{s}.yml"))[m_name]
      end
    end

    # data_object is a BrattyResponse ducktype
    attr_reader :service_name, :model_name, :data_object
    def initialize(_service_name, _model_name, _data_obj)
      @service_name = _service_name.to_s.downcase
      @model_name = _model_name.to_s.downcase
      @data_object = _data_obj
      @parsed_data_object = parse_data_obj
    end


    private

      def parse_data_obj
        # obj_config = load_config(@service_name, @model_name)
        # h = HashWithIndifferentAccess.new

        # obj_config['fields'].each do |f|
        #   field_name = f['name']
        #   if f['path'].nil?
        #     h[field_name] = @data_object[f]
        #   else
        #     val = f['path']
        #     while val.is_a?(Hash)
        #       nkey = val.keys[0]
        #       val = val[nkey]
        #     end

        #     h[field_name] = val
        #   end

        # end

        return {}
      end


  end
end
