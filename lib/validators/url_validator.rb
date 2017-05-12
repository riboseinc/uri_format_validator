require 'active_model'
require 'uri'

module ActiveModel
  module Validations
    class UrlValidator < ::ActiveModel::EachValidator

      attr_accessor :schemes

      def initialize(options)
        options.merge!(:schemes => %w(http https))
        options.reverse_merge!(:message => "is not a valid URL")
        @schemes = options[:schemes]
        super(options)
      end

      def validate_each(record, attribute, value)
        unless value.slice(URI::regexp(schemes))
          record.errors[attribute] << options[:message]
          return
        end

        unless value =~ regexp
          record.errors[attribute] << options[:message]
        end
      end

      private

      def regexp
        protocol = "(#{schemes.join('|')})://"
        /^#{protocol}[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$/iux
      end
    end
  end
end
