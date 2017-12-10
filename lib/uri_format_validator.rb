# (c) Copyright 2017 Ribose Inc.
#

require "uri_format_validator/version"
require "uri_format_validator/util"
require "uri_format_validator/constraints"
require "uri_format_validator/localization"
require "uri_format_validator/reacher"
require "uri_format_validator/validators"

# This is a placeholder...
module UriFormatValidator
  # Your code goes here...
end

ActiveModel::Validations.include UriFormatValidator::Validators
