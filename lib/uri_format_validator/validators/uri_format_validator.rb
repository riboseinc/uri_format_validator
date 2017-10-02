# (c) Copyright 2017 Ribose Inc.
#

require "active_model"
require "uri"
require "active_support/core_ext"
require "net/http"
require "resolv"

module UriFormatValidator
  module Validators
    #
    # TODO: documentation
    #
    class UriFormatValidator < ::ActiveModel::EachValidator
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

      # Examples: http://www.rubular.com/r/Xy4iNY2ztf
      RESERVED_DOMAINS = %r{
        (\.(test|example|invalid|localhost)$)|
        ((^|\.)example\.(...?)(\...)?$)
      }x

      def initialize(options)
        @schemes =
          case options[:scheme]
          when :all then SCHEMES
          when nil then %w[http https]
          else options[:scheme]
          end

        options[:message] ||= I18n.t("errors.messages.invalid_uri")
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
      SUCCESSFUL_HTTP_STATUSES = 200..399
      RESOLVABILITY_SUPPORTED_SCHEMES = %w[http https].freeze

      def do_checks(uri_string)
        uri = string_to_uri(uri_string)
        fail_unless uri

        if accept_relative_uris?
          validate_domain_absense(uri)
        else
          validate_domain(uri_string)
          validate_against_options(uri, :authority, :scheme, :retrievable)
        end

        validate_against_options(uri, :path, :query, :fragment)
      end

      # Warning!  The +URI+ method behaviour is inconsistent across VMs.
      # For instance, Rubinius allows leading and trailing spaces.  Non-nil
      # return value doesn't guarantee that URI is indeed well-formed.
      def string_to_uri(uri_string)
        URI(uri_string)
      rescue URI::InvalidURIError
        nil
      end

      def set_failure_message(record, attribute)
        record.errors[attribute] << options[:message]
      end

      def fail_if(condition)
        throw STOP_VALIDATION if condition
      end

      def fail_unless(condition)
        fail_if !condition
      end

      def validate_domain(uri)
        fail_unless uri =~ regexp
      end

      def validate_against_options(uri, *option_keys_list)
        option_keys_list.each do |option_name|
          next unless options.key?(option_name)
          send(:"validate_#{option_name}", options[option_name], uri)
        end
      end

      def validate_scheme(_option, uri)
        scheme = uri.scheme
        if @schemes.is_a?(Regexp)
          fail_if scheme !~ @schemes
        else
          fail_unless @schemes.include?(scheme)
        end
      end

      def validate_path(option, uri)
        path = uri.path
        fail_if option == true  && path == "/" || path == ""
        fail_if option == false && path != "/" && path != ""
        fail_if option.is_a?(Regexp) && path !~ option
      end

      def validate_query(option, uri)
        fail_unless uri.query.present? == option
      end

      def validate_fragment(option, uri)
        fail_unless uri.fragment.present? == option
      end

      def validate_authority(option, uri)
        fail_if option.is_a?(Regexp) && uri.host !~ option
        fail_if option.is_a?(Array) && !option.include?(uri.host)

        if option.is_a?(Hash) && option[:allow_reserved] == false
          check_reserved_domains(uri)
        end
      end

      def validate_retrievable(option, uri)
        fail_unless Reacher.new(uri).retrievable? if option
      end

      def accept_relative_uris?
        options.key?(:authority) && options[:authority] == false
      end

      def validate_domain_absense(uri)
        fail_if uri.host.present?
      end

      def check_reserved_domains(uri)
        fail_if uri.host =~ RESERVED_DOMAINS
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
  end
end
