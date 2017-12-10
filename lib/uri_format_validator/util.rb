require "ipaddr"

module UriFormatValidator
  module Util
    module_function

    # Attempts to convert passed string which is expected to contain a host name
    # to a more suitable class.
    #
    # For blank strings, it returns +nil+. For strings which look like an IP
    # address, it returns an instance of +IPAddr+. Otherwise, it returns
    # the unmodified argument (domain name).
    #
    # IPv6 addresses are allowed to be surrounded with square brackets,
    # as they show up in URIs.
    def parse_host(hostname)
      return nil if hostname.blank?

      begin
        return IPAddr.new(hostname)
      rescue IPAddr::InvalidAddressError
      end

      hostname
    end
  end
end
