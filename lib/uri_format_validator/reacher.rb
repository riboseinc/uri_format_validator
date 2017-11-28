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
      http_or_https? && head_response.is_a?(Net::HTTPSuccess)
    end

    private

    def head_response
      Net::HTTP.start(url.hostname, url.port, use_ssl: use_ssl?) do |http|
        http.request_head(url)
      end
    rescue StandardError
      # The NET::HTTP may raise so many different errors that listing them all
      # is IMO pretty pointless.
      # See: http://tammersaleh.com/posts/rescuing-net-http-exceptions/
      # for *incomplete* list.
      nil
    end

    def use_ssl?
      url.scheme == "https"
    end

    def http_or_https?
      %w[http https].include? url.scheme
    end
  end
end
