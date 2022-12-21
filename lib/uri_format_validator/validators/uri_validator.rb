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
      attr_reader :accept_list, :reject_list

      ALLOW_ALL_OPTION_HASH = {}.freeze

      def initialize(options)
        build_white_and_black_lists(options)
        super(options)
      end

      def validate_each(record, attribute, value)
        uri = string_to_uri(value)
        unless uri && fits_accept_and_reject_lists? { |c| c.match?(uri) }
          set_failure_message(record, attribute)
        end
      end

      private

      def build_white_and_black_lists(options)
        accept_l, reject_l = options.values_at(:accept, :reject)
        accept_l ||= reject_l ? [ALLOW_ALL_OPTION_HASH] : options

        @accept_list = Array.wrap(accept_l).map { |o| Constraints.new(o) }
        @reject_list = Array.wrap(reject_l).map { |o| Constraints.new(o) }
      end

      def fits_accept_and_reject_lists?(&block)
        accept_list.any?(&block) && reject_list.none?(&block)
      end

      def string_to_uri(uri_string)
        uri = Addressable::URI.parse(uri_string)

        # no scheme nor host
        if uri.scheme.nil? || uri.host.nil?
          return nil 
        end

        # host does not contain dot with at least one letter
        unless uri.host.match(/\.[a-zA-z]/)
          return nil 
        end

        uri
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
