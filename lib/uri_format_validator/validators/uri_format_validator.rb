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
        begin
          uri = URI(uri_string.to_s)
        rescue URI::InvalidURIError
          fail_if true
        end

        if accept_relative_uris?
          validate_domain_absense(uri)
        else
          validate_domain(uri_string)
          validate_authority(options[:authority], uri) if options.key?(:authority)
          validate_scheme(options[:scheme], uri.scheme) if options.key?(:scheme)

          if options.key?(:resolvability)
            case options[:resolvability]
            when :resorvable then validate_resorvable(uri.to_s)
            when :reachable then validate_reachable(uri)
            when :retrievable then validate_retrievable(uri)
            else
              msg = "Invalid option for 'resolvability', valid options are: \
                    :resorvable, :reachable, :retrievable"
              raise ArgumentError.new(msg)
            end
          end
        end

        %i[path query fragment].each do |prop|
          next unless options.key?(prop)
          send(:"validate_#{prop}", options[prop], uri.send(prop))
        end
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

      def validate_scheme(_option, scheme)
        if @schemes.is_a?(Regexp)
          fail_if scheme !~ @schemes
        else
          fail_unless @schemes.include?(scheme)
        end
      end

      def validate_path(option, path)
        fail_if option == true  && path == "/" || path == ""
        fail_if option == false && path != "/" && path != ""
        fail_if option.is_a?(Regexp) && path !~ option
      end

      def validate_query(option, query)
        fail_unless query.present? == option
      end

      def validate_fragment(option, fragment)
        fail_unless fragment.present? == option
      end

      def validate_authority(option, uri)
        fail_if option.is_a?(Regexp) && uri.host !~ option
        fail_if option.is_a?(Array) && !option.include?(uri.host)

        if option.is_a?(Hash) && option[:allow_reserved] == false
          check_reserved_domains(uri)
        end
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

      # TODO:
      # host exists and resolves to an ip address
      def validate_resorvable(uri)
        !Resolv.getaddress(uri).nil?
      rescue Resolv::ResolvError, Resolv::ResolvTimeout
        false
      rescue
        nil
      end

      # uri responds with something
      def validate_reachable(uri)
        res = generic_validate_retrievable(uri)
        if res
          res.code.to_i != 404
        else
          res
        end
      end

      # uri responds with 2xx >= x <= 399
      def validate_retrievable(uri)
        res = generic_validate_retrievable(uri)
        if res
          SUCCESSFUL_HTTP_STATUSES.include?(res.code.to_i)
        else
          res
        end
      end

      def scheme_supports_resolvability!(uri)
        sch = uri.schema
        if RESOLVABILITY_SUPPORTED_SCHEMES.include?(sch)
          true
        else
          msg = "The scheme #{sch} not supported for resolvability validation. \
                Supported schemes: #{REACHABILITY_SUPPORTED_SCHEMES}"
          raise ArgumentExcpeption.new(msg)
        end
      end

      def use_https?(uri)
        uri.scheme == "https" ||
          (uri.scheme.nil? && @schemes.try(:include?, "https"))
      end

      def generic_validate_retrievable(uri)
        scheme_supports_resolvability!(uri)
        req = Net::HTTP.new(uri.host, uri.port)
        req.use_ssl = use_https?(uri)
        path = uri.path.present? ? uri.path : "/"
        req.request_head(path)
      rescue Errno::ENOENT
        false
      rescue
        nil
      end
    end
  end
end
