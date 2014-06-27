require 'action_view/helpers/number_helper'
require 'chronic'

module BrattyPack
  class DataThing < SimpleDelegator
    include ActionView::Helpers::NumberHelper

    # array is an Array of pair-arrays:
    # [[opts_hash_1, val_1], [opts_hash_2, val_2]]
    def initialize(array = [])
      @_columns = array.inject({}) do |hsh, a|
        att = make_attribute(*a)
        hsh[att[:name]] = att

        hsh
      end

    end

    def attributes
      @_columns
    end

    def [](att_name)
      if( a = attributes[att_name] )
        return a
      end
    end



    private
      def make_attribute(hsh, val)
        opts = HashWithIndifferentAccess.new(hsh)
        att = HashWithIndifferentAccess.new
        att[:value] = val
        att[:name] = opts[:name]
        att[:type] = (opts[:type] || 'string').to_sym

        att[:formatted_value] = case att[:type]
        when :numeric
          number_with_delimiter val
        when :text
          txt = val.to_s
          txt.length > 255 ? txt[0..255] + '...' : txt
        when :datetime
          Chronic.parse(val).strftime("%Y-%m-%d %H:%M:%S")
        when :uuid_url, :url
          val.to_s.gsub(/\/(?!=\/)/, "/\n")
        else
          val
        end


        return att
      end
  end
end
