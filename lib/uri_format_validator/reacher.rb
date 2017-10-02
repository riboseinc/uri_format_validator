# (c) Copyright 2017 Ribose Inc.
#

require "net/http"

module UriFormatValidator
  # Reacher is a minimalist net client which purpose is to determine whether
  # given URL is resolvable, host is reachable, and content is retrievable.
  class Reacher
    attr_reader :url

    def initialize(url)
      @url = url
    end

    # Tests whether given +url+ is retrievable, that is making a HEAD request
    # results with 2xx status code.
    def retrievable?
      head_response.is_a?(Net::HTTPSuccess)
    end

    private

    def head_response
      Net::HTTP.start(url.hostname, url.port, use_ssl: use_ssl?) do |http|
        http.request_head(url)
      end
    rescue
      # FIXME The rescue-all clause should be replaced with sth specific
      nil
    end

    def use_ssl?
      url.scheme == "https"
    end
  end
end
