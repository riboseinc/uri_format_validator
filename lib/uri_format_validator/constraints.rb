# (c) Copyright 2017 Ribose Inc.
#

require "active_model"
require "addressable"
require "active_support/core_ext"
require "net/http"
require "resolv"

module UriFormatValidator
  class Constraints
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def match?(uri)
      success = catch(STOP_VALIDATION) do
        do_checks(uri)
        true
      end
      !!success
    end

    private

    STOP_VALIDATION = Object.new.freeze

    def do_checks(uri)
      validate_against_options(uri, :scheme, :host, :retrievable)
    end

    def invalid
      throw STOP_VALIDATION
    end

    def validate_against_options(uri, *option_keys_list)
      option_keys_list.each do |option_name|
        next unless options[option_name]
        send(:"validate_#{option_name}", options[option_name], uri)
      end
    end

    def validate_host(host_or_hosts, uri)
      hosts = Array.wrap(host_or_hosts)
      invalid unless hosts.any? { |h| h === uri.hostname }
    end

    def validate_scheme(scheme_or_schemes, uri)
      schemes = Array.wrap(scheme_or_schemes)
      invalid unless schemes.any? { |s| s === uri.scheme }
    end

    def validate_retrievable(option, uri)
      invalid if option && !Reacher.new(uri).retrievable?
    end
  end
end
