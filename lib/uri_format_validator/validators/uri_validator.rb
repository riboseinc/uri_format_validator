# (c) Copyright 2017 Ribose Inc.
#

require "active_model"
require "addressable"
require "active_support/core_ext"
require "net/http"
require "resolv"

module UriFormatValidator
  module Validators
    #
    # TODO: documentation
    #
    class UriValidator < ::ActiveModel::EachValidator
      def initialize(options)
        super(options)
      end

      def validate_each(record, attribute, value)
        success = catch(STOP_VALIDATION) do
          do_checks(value.to_s)
          true
        end
        success || set_failure_message(record, attribute)
      end

      private

      STOP_VALIDATION = Object.new.freeze

      def do_checks(uri_string)
        uri = string_to_uri(uri_string)
        invalid unless uri

        validate_against_options(uri, :scheme, :retrievable)
      end

      def string_to_uri(uri_string)
        Addressable::URI.parse(uri_string)
      rescue Addressable::URI::InvalidURIError
        nil
      end

      def set_failure_message(record, attribute)
        record.errors[attribute] << failure_message
      end

      def invalid
        throw STOP_VALIDATION
      end

      def validate_against_options(uri, *option_keys_list)
        option_keys_list.each do |option_name|
          next unless options[option_name]
          send(:"validate_#{option_name}", options[option_name], uri)
        end
      end

      def validate_scheme(scheme_or_schemes, uri)
        schemes = Array.wrap(scheme_or_schemes)
        invalid unless uri.scheme.in?(schemes)
      end

      def validate_retrievable(option, uri)
        invalid if option && !Reacher.new(uri).retrievable?
      end

      def failure_message
        options[:message] || I18n.t("errors.messages.invalid_uri")
      end
    end
  end
end
