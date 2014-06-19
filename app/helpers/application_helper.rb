module BrattyPack
  module Helpers
    module ApplicationHelper
      def clean_textfield(txt)
        txt.split(/,|\s/).map{|s| s.strip }.reject{|s| s.empty? }
      end
    end
  end
end
