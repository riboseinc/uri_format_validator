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

        url = URI(value)
        ok = true

        ok &&= validate_path(options[:path], url.path) if options.has_key?(:path)
        ok &&= validate_query(options[:query], url.query) if options.has_key?(:query)
        ok &&= validate_fragment(options[:fragment], url.fragment) if options.has_key?(:fragment)

        record.errors[attribute] << options[:message] unless ok
      end

      private

      def validate_path option, path
        if option == true
          return false if path == '/' || path == ''
        end
        if option == false
          return false unless path == '/' || path == ''
        end
        if option.is_a?(Regexp)
          return false unless path =~ option
        end
        true
      end

      def validate_query option, query
        query.present? == option
      end

      def validate_fragment option, fragment
        fragment.present? == option
      end


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
