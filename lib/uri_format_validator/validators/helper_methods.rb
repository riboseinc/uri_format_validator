# (c) Copyright 2017 Ribose Inc.
#

require "active_model"

module UriFormatValidator
  module Validators
    module HelperMethods
      # Encapsulates the pattern of wanting to validate an URL.
      #
      #   class Post < ActiveRecord::Base
      #     validates_uri_format_of :permalink
      #   end
      def validates_uri_format_of(*attr_names)
        validates_with UriValidator, _merge_attributes(attr_names)
      end
    end
  end
end
