module BrattyPack
  module Helpers
    module ApplicationHelper

      # splits either by newline OR comma
      def process_text_input_array(tf)
        txt = tf.to_s.strip # first, strip out newlines

        (txt =~ /\n/ ? txt.split("\n") : txt.split(',')).
          map{|s| s.strip }.reject{|s| s.empty? }
      end
    end
  end
end
