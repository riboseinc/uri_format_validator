require 'active_model'
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
        options[:message] ||= I18n.t('errors.messages.invalid_url')
        @schemes = options[:schemes]
        super(options)
      end

      def validate_each(record, attribute, value)
        unless value.to_s.slice(URI.regexp(schemes))
          record.errors[attribute] << options[:message]
          return
        end

        url = URI(value)
        valid = catch(:invalid) do
          validate_domain(value)
          validate_path(options[:path], url.path) if options.key?(:path)
          validate_query(options[:query], url.query) if options.key?(:query)
          validate_fragment(options[:fragment], url.fragment) if options.key?(:fragment)
          true # valid
        end

        record.errors[attribute] << options[:message] unless valid
      end

      private

      def validate_domain(url)
        throw :invalid unless url =~ regexp
      end

      def validate_path(option, path)
        throw :invalid if option == true && path == '/' || path == ''
        throw :invalid if option == false && path != '/' && path != ''
        throw :invalid if option.is_a?(Regexp) && path !~ option
      end

      def validate_query(option, query)
        throw :invalid unless query.present? == option
      end

      def validate_fragment(option, fragment)
        throw :invalid unless fragment.present? == option
      end

      def regexp
        protocol = "(#{schemes.join('|')})://"
        %r{^#{
          protocol
        }[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$}iux
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
