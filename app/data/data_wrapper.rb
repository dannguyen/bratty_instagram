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
    attr_reader :service_name, :model_name, :original_data_object, :data
    def initialize(_service_name, _model_name, _data_obj)
      @service_name = _service_name.to_s.downcase
      @model_name = _model_name.to_s.downcase
      @original_data_object = _data_obj
      @data = parse_data_obj
    end



    private

      def parse_data_obj
        obj_config = self.class.load_config(@service_name, @model_name)
        h = HashWithIndifferentAccess.new

        obj_config['fields'].each do |field|
          field_name = field['name']
          field_path = field['path']
          if field_path.nil?
            h[field_name] = @original_data_object[field_name]
          else
            kval = field_path.keys[0]    # :counts
            fpath = field_path[kval]     # { :counts => :media }[:counts]
            obj = @original_data_object[kval]  # {counts: {media: 100 }}

            while fpath.is_a?(Hash)
              kval = field_path.keys[0]
              fpath = field_path[kval]
              obj = obj[kval]

              # fpath = fpath[kval]
              #
              # kval = fpath.keys[0]
              # obj = obj[kval]
              # binding.pry
            end

            h[field_name] = obj[fpath]
          end
        end

        return h
      end


  end
end
