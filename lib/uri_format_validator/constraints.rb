# (c) Copyright 2017 Ribose Inc.
#

require "active_support"
require "active_support/core_ext"

module UriFormatValidator
  class Constraints
    attr_reader :options

    def initialize(options)
      @options = options
    end

    def match?(uri)
      success = catch(URI_MISMATCH) do
        do_checks(uri)
        true
      end
      !!success
    end

    private

    URI_MISMATCH = Object.new.freeze

    def do_checks(uri)
      check_against_options(uri, :scheme, :host, :resolvable, :retrievable)
    end

    def mismatch
      throw URI_MISMATCH
    end

    def check_against_options(uri, *option_keys_list)
      option_keys_list.each do |option_name|
        next unless options[option_name]
        send(:"check_#{option_name}", options[option_name], uri)
      end
    end

    def check_host(host_or_hosts, uri)
      hosts = Array.wrap(host_or_hosts)
      mismatch unless hosts.any? { |h| host_matches?(h, uri.hostname) }
    end

    def check_scheme(scheme_or_schemes, uri)
      schemes = Array.wrap(scheme_or_schemes)
      mismatch unless schemes.any? { |s| s === uri.scheme }
    end

    def check_resolvable(option, uri)
      mismatch if option && !Reacher.new(uri).resolvable?
    end

    def check_retrievable(option, uri)
      mismatch if option && !Reacher.new(uri).retrievable?
    end

    def host_matches?(expectation, candidate)
      case expectation
      when Regexp
        expectation.match(candidate)
      when String
        Util.hosts_eql?(expectation, candidate)
      else
        false
      end
    end
  end
end
