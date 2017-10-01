# (c) Copyright 2017 Ribose Inc.
#

module UriFormatValidator
  # Reacher is a minimalist net client which purpose is to determine whether
  # given URL is resolvable, host is reachable, and content is retrievable.
  class Reacher
    attr_reader :url

    def initialize(url)
      @url = url
    end
  end
end
