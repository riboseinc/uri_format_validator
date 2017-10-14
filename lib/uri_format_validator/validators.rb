# (c) Copyright 2017 Ribose Inc.
#

require "uri_format_validator/validators/uri_validator"
require "uri_format_validator/validators/helper_methods"

module UriFormatValidator
  module Validators
    extend ActiveSupport::Concern

    included do
      extend  HelperMethods
      include HelperMethods
    end
  end
end
