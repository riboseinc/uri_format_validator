require 'active_model'
require 'active_support/core_ext'
require 'uri'

module ActiveModel
  module Validations
    #
    # TODO: documentation
    #
    class UrlValidator < ::ActiveModel::EachValidator
      SCHEMES = %w[
        aaa aaas about acap acct cap cid coap coaps crid data dav dict dns
        example file ftp geo go gopher h323 http https iax icap im imap info ipp
        ipps iris iris.beep iris.lwz iris.xpc iris.xpcs jabber ldap mailto mid
        msrp msrps mtqp mupdate news nfs ni nih nntp opaquelocktoken pkcs11 pop
        pres reload rtsp rtsps rtspu service session shttp sieve sip sips sms
        snmp soap.beep soap.beeps stun stuns tag tel telnet tftp thismessage tip
        tn3270 turn turns tv urn vemmi vnc ws wss xcon xcon-userid xmlrpc.beep
        xmlrpc.beeps xmpp z39.50r z39.50s
      ].freeze

      def initialize(options)
        @schemes =
          case options[:scheme]
          when true then SCHEMES
          when nil then %w[http https]
          else options[:scheme]
          end

        options.reverse_merge!(message: 'is not a valid URL')
        super(options)
      end

      def validate_each(record, attribute, value)
        url = URI(value.to_s)
        valid = catch(:invalid) do
          validate_domain(value)
          validate_scheme(options[:scheme], url.scheme) if options.key?(:scheme)
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

      def validate_scheme(_option, scheme)
        if @schemes.is_a?(Regexp)
          throw :invalid if scheme !~ @schemes
        else
          throw :invalid unless @schemes.include?(scheme)
        end
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
        protocol =
          if @schemes.is_a?(Regexp)
            "(#{@schemes.source})://"
          else
            "(#{@schemes.join('|')})://"
          end

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
