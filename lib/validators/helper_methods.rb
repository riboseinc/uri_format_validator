require "active_model"

module ActiveModel
  module Validations
    module HelperMethods
      # Encapsulates the pattern of wanting to validate an URL.
      #
      #   class Post < ActiveRecord::Base
      #     validates_url_of :permalink
      #   end
      def validates_url_of(*attr_names)
        validates_with UriFormatValidator, _merge_attributes(attr_names)
      end
    end
  end
end
