require 'active_model'
require 'active_support/core_ext'
require 'uri'

module ActiveModel
  module Validations
    #
    # TODO: documentation
    #
    class UrlValidator < ::ActiveModel::EachValidator
      attr_accessor :schemes

      def initialize(options)
        options[:schemes] = %w[http https]
        options.reverse_merge!(message: 'is not a valid URL')
        @schemes = options[:schemes]
        super(options)
      end

      def validate_each(record, attribute, value)
        unless value.to_s.slice(URI.regexp(schemes))
          record.errors[attribute] << options[:message]
          return
        end

        record.errors[attribute] << options[:message] unless value =~ regexp
      end

      private

      def regexp
        protocol = "(#{schemes.join('|')})://"
        %r{^#{
          protocol
        }[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$}iux
      end
    end
  end
end
