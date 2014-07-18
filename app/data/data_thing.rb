require 'action_view/helpers/number_helper'
require 'chronic'

# The purpose of PresentableDataThing is to wrap the received data and
# make it presentable for HTML
#
# TK: need to give PresentableDataThing a better name,
# but it essentially acts as an object that contains some metadata
# for each attribute
#
#
# e.g. for a Twitter user's :followers_count
#  it has :type => :numeric
#         :value => (the value as an Integer)
#         :formatted_value => (the value as a comma delimited string)

module BrattyPack
  class PresentableDataThing < SimpleDelegator
    include ActionView::Helpers::NumberHelper

    # array is an Array of pair-arrays:
    # [[opts_hash_1, val_1], [opts_hash_2, val_2]]
    def initialize(array = [])
      @_columns = array.inject({}) do |hsh, a|
        att = make_attribute(*a)
        hsh[att[:name]] = att

        hsh
      end

      # return a flattened hash
      super(flattened_data)

    end

    def attributes
      @_columns
    end

    # this returns a whole attribute and its meta hsh
    # e.g.
    # x['id']
    #   => "1574083"
    # x.read_attribute('id')
    #   => {"value"=>"1574083", "name"=>"id", "type"=>:string, "formatted_value"=>"1574083"}
    def read_attribute(att_name)
      if( a = attributes[att_name] )
        return a
      end
    end



    private

      def flattened_data
        @_columns.inject({}) do |h, (att_name, att_hsh)|
          h[att_name] = att_hsh['value']

          h
        end
      end

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
            # TK todo: handle funky timezoning of twitter and facebook
            v = val.to_s
            if v =~ /^\d{6,}$/
              Time.at val.to_i
            elsif v.empty?
              nil
            else
              Chronic.parse(v).strftime("%Y-%m-%d %H:%M:%S")
            end
          when :uuid_url, :url
            val.to_s.gsub(/\/(?!=\/)/, "/\n")
          else
            val
        end


        return att
      end
  end
end
