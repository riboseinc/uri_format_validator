require 'active_model'
require 'active_support/core_ext'
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
        unless value.to_s.slice(URI::regexp(schemes))
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

    module HelperMethods
      # Encapsulates the pattern of wanting to validate an URL.
      #
      #   class Post < ActiveRecord::Base
      #     validates_url_of :permalink
      #   end
      def validates_url_of(*attr_names)
        validates_with UrlValidator, _merge_attributes(attr_names)
      end
    end
  end
end
