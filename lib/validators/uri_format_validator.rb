# (c) Copyright 2017 Ribose Inc.
#

require "active_model"
require "uri"
require "active_support/core_ext"
require "net/http"
require "resolv"

module ActiveModel
  module Validations
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

        options[:message] ||= I18n.t("errors.messages.invalid_url")
        super(options)
      end

      def validate_each(record, attribute, value)
        success = catch(STOP_VALIDATION) do
          do_checks(value.to_s)
          true
        end
        success || set_failure_message(record, attribute)
      rescue URI::InvalidURIError
        # The rescue clause is still required because URI() may raise exception.
        set_failure_message(record, attribute)
      end

      private

      STOP_VALIDATION = Object.new.freeze
      SUCCESSFUL_HTTP_STATUSES = 200..399
      RESOLVABILITY_SUPPORTED_SCHEMES = %w[http https].freeze

      def do_checks(url_string)
        url = URI(url_string.to_s)
        if accept_relative_urls?
          validate_domain_absense(url)
        else
          validate_domain(url_string)
          validate_authority(options[:authority], url) if options.key?(:authority)
          validate_scheme(options[:scheme], url.scheme) if options.key?(:scheme)

          if options.key?(:resolvability)
            case options[:resolvability]
            when :resorvable then validate_resorvable(url.to_s)
            when :reachable then validate_reachable(url)
            when :retrievable then validate_retrievable(url)
            else
              msg = "Invalid option for 'resolvability', valid options are: \
                    :resorvable, :reachable, :retrievable"
              raise ArgumentError.new(msg)
            end
          end
        end

        %i[path query fragment].each do |prop|
          send(:"validate_#{prop}", options[prop], url.send(prop)) if options.key?(prop)
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

      def validate_domain(url)
        fail_unless url =~ regexp
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

      def validate_authority(option, url)
        fail_if option.is_a?(Regexp) && url.host !~ option
        fail_if option.is_a?(Array) && !option.include?(url.host)
        check_reserved_domains(url) if option.is_a?(Hash) &&
                                       option[:allow_reserved] == false
      end

      def accept_relative_urls?
        options.key?(:authority) && options[:authority] == false
      end

      def validate_domain_absense(url)
        fail_if url.host.present?
      end

      def check_reserved_domains(url)
        fail_if url.host =~ RESERVED_DOMAINS
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
      def validate_resorvable(url)
        Resolv.getaddress(url) != nil
      rescue Resolv::ResolvError, Resolv::ResolvTimeout
        false
      rescue
        nil
      end

      # url responds with something
      def validate_reachable(url)
        res = generic_validate_retrievable(url)
        if res
          res.code.to_i != 404
        else
          res
        end
      end

      # url responds with 2xx >= x <= 399
      def validate_retrievable(url)
        res = generic_validate_retrievable(url)
        if res
          SUCCESSFUL_HTTP_STATUSES.include?(res.code.to_i)
        else
          res
        end
      end

      def scheme_supports_resolvability!(url)
        sch = url.schema
        if RESOLVABILITY_SUPPORTED_SCHEMES.include?(sch)
          true
        else
          msg = "The scheme #{sch} not supported for resolvability validation. \
                Supported schemes: #{REACHABILITY_SUPPORTED_SCHEMES}"
          raise ArgumentExcpeption.new(msg)
        end
      end

      def use_https?(url)
        url.scheme == "https" ||
          (url.scheme == nil && @schemes.is_a?(Array) && @schemes.include?("https"))
      end

      def generic_validate_retrievable(url)
        scheme_supports_resolvability!(url)
        req = Net::HTTP.new(url.host, url.port)
        req.use_ssl = use_https?(url)
        path = url.path.present? ? url.path : "/"
        req.request_head(path)
      rescue Errno::ENOENT
        false
      rescue
        nil
      end
    end
  end
end
