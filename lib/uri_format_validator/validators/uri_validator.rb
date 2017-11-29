# (c) Copyright 2017 Ribose Inc.
#

require "active_model"
require "addressable"

module UriFormatValidator
  module Validators
    #
    # TODO: documentation
    #
    class UriValidator < ::ActiveModel::EachValidator
      attr_reader :constraints

      def initialize(options)
        @constraints = Constraints.new(options)
        super(options)
      end

      def validate_each(record, attribute, value)
        uri = string_to_uri(value)
        unless uri && constraints.match?(uri)
          set_failure_message(record, attribute)
        end
      end

      private

      def string_to_uri(uri_string)
        Addressable::URI.parse(uri_string)
      rescue Addressable::URI::InvalidURIError
        nil
      end

      def set_failure_message(record, attribute)
        record.errors[attribute] << failure_message
      end

      def failure_message
        options[:message] || I18n.t("errors.messages.invalid_uri")
      end
    end
  end
end
