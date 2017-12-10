# (c) Copyright 2017 Ribose Inc.
#

require "spec_helper"

RSpec.describe UriFormatValidator::Constraints do
  subject { described_class.new(validation_options) }

  describe ":host option" do
    let(:http_uri) { "http://example.com/relative/path" }
    let(:https_uri) { "https://example.com/different/path" }
    let(:subdomain_uri) { "http://another.example.com/different/path" }
    let(:http_ipv6_uri) { "http://[::1]/relative/path" }
    let(:local_file_uri) { "file:///dev/null" }
    let(:urn) { "urn:ISSN:0167-6423" }

    before do
      Post.validates :url, uri: validation_options
    end

    context "when unspecified" do
      let(:validation_options) { {} }

      it "allows URIs with any host subcomponent" do
        allow_uri(http_uri)
        allow_uri(https_uri)
        allow_uri(subdomain_uri)
        allow_uri(http_ipv6_uri)
      end

      it "allows URIs which host subcomponent is missing" do
        allow_uri(local_file_uri)
        allow_uri(urn)
      end
    end

    context "when is false" do
      let(:validation_options) { { host: false } }

      it "allows URIs with any host subcomponent" do
        allow_uri(http_uri)
        allow_uri(https_uri)
        allow_uri(subdomain_uri)
        allow_uri(http_ipv6_uri)
      end

      it "allows URIs which host subcomponent is missing" do
        allow_uri(local_file_uri)
        allow_uri(urn)
      end
    end

    context "when is a string" do
      let(:validation_options) { { host: "example.com" } }

      it "allows URIs which host subcomponent equals to specified string" do
        allow_uri(http_uri)
        allow_uri(https_uri)
      end

      it "disallows URIs which host subcomponent is different than specified \
          string, even if it's a subdomain of that string" do
        disallow_uri(subdomain_uri)
        disallow_uri(http_ipv6_uri)
      end

      it "disallows URIs which host subcomponent is missing" do
        disallow_uri(local_file_uri)
        disallow_uri(urn)
      end

      context "which represents an IPv6 address" do
        let(:validation_options) { { host: "0000::0:1" } }

        it "recognizes various ways of text representation of the address" do
          # See RFC 4291 "IPv6 Addressing Architecture", section 2.2.
          # https://tools.ietf.org/html/rfc4291#section-2.2
          allow_uri("http://[0000::0:1]")
          allow_uri("http://[0000:0000:0000:0000:0000:0000:0000:0001]")
          allow_uri("http://[0:0:0:0:0:0:0:1]")
          allow_uri("http://[::1]")
          allow_uri("http://[0:0:0::0001]")
          disallow_uri("http://[::2]")
          disallow_uri("http://[::]")
        end
      end
    end

    context "when is a regular expression" do
      let(:validation_options) { { host: /\.example\.com$/ } }

      it "allows URIs which host subcomponent matches the regular expression" do
        allow_uri(subdomain_uri)
      end

      it "disallows URIs which host subcomponent does not match the regular \
          expression" do
        disallow_uri(http_uri)
        disallow_uri(https_uri)
        disallow_uri(http_ipv6_uri)
      end

      it "disallows URIs which host subcomponent is missing" do
        disallow_uri(local_file_uri)
        disallow_uri(urn)
      end
    end

    context "when is an array of strings or regular expressions" do
      let(:validation_options) do
        { host: [/^example\.(com|test)$/, "::1"] }
      end

      it "allows URIs which host subcomponent matches any element of \
          the specified array" do
        allow_uri(http_uri)
        allow_uri(https_uri)
        allow_uri(http_ipv6_uri)
      end

      it "disallows URIs which host subcomponent matches neither element of \
          the specified array" do
        disallow_uri(subdomain_uri)
      end

      it "disallows URIs which host subcomponent is missing" do
        disallow_uri(local_file_uri)
        disallow_uri(urn)
      end
    end
  end

  describe ":scheme option" do
    let(:http_uri) { "http://example.com/relative/path" }
    let(:https_uri) { "https://another.example.com/different/path" }
    let(:file_uri) { "file:///dev/null" }

    before do
      Post.validates :url, uri: validation_options
    end

    context "when unspecified" do
      let(:validation_options) { {} }

      it "allows URIs with any scheme" do
        allow_uri(http_uri)
        allow_uri(https_uri)
        allow_uri(file_uri)
      end
    end

    context "when is false" do
      let(:validation_options) { { scheme: false } }

      it "allows URIs with any scheme" do
        allow_uri(http_uri)
        allow_uri(https_uri)
        allow_uri(file_uri)
      end
    end

    context "when is a string" do
      let(:validation_options) { { scheme: "https" } }

      it "only allows URIs with scheme equal to passed option" do
        disallow_uri(http_uri)
        allow_uri(https_uri)
        disallow_uri(file_uri)
      end
    end

    context "when is a regular expression" do
      let(:validation_options) { { scheme: /^https?$/ } }

      it "only allows URIs with scheme matching the passed option" do
        allow_uri(http_uri)
        allow_uri(https_uri)
        disallow_uri(file_uri)
      end
    end

    context "when is an array of strings or regular expressions" do
      let(:validation_options) { { scheme: ["http", /s/] } }

      it "only allows URIs with schemes matching any of constraints in \
          that array" do
        allow_uri(http_uri)
        allow_uri(https_uri)
        disallow_uri(file_uri)
      end
    end
  end

  describe ":retrievable option" do
    let(:retrievable_http_url) { "http://example.com/relative/path" }
    let(:retrievable_https_url) { "https://example.com/relative/path" }
    let(:unretrievable_http_url) { "http://example.com/does/not/exist" }
    let(:retrievable_ssh_url) { "ssh://git@github.com/riboseinc/some_repo.git" }

    before do
      Post.validates :url, uri: validation_options

      stub_request(:head, retrievable_http_url).to_return(status: 200)
      stub_request(:head, retrievable_https_url).to_return(status: 200)
      stub_request(:head, unretrievable_http_url).to_return(status: 404)
      stub_request(:head, retrievable_ssh_url).to_return(status: 200)
    end

    context "when unspecified" do
      let(:validation_options) { {} }

      it "allows URI with http scheme which points to retrievable content" do
        allow_uri(retrievable_http_url)
      end

      it "allows URI with https scheme which points to retrievable content" do
        allow_uri(retrievable_https_url)
      end

      it "allows URI which points to unretrievable content" do
        allow_uri(unretrievable_http_url)
      end

      it "allows URI which scheme is different than http or https" do
        allow_uri(retrievable_ssh_url)
      end
    end

    context "when is false" do
      let(:validation_options) { { retrievable: false } }

      it "allows URI with http scheme which points to retrievable content" do
        allow_uri(retrievable_http_url)
      end

      it "allows URI with https scheme which points to retrievable content" do
        allow_uri(retrievable_https_url)
      end

      it "allows URI which points to unretrievable content" do
        allow_uri(unretrievable_http_url)
      end

      it "allows URI which scheme is different than http or https" do
        allow_uri(retrievable_ssh_url)
      end
    end

    context "when is true" do
      let(:validation_options) { { retrievable: true } }

      it "allows URI with http scheme which points to retrievable content" do
        allow_uri(retrievable_http_url)
      end

      it "allows URI with https scheme which points to retrievable content" do
        allow_uri(retrievable_https_url)
      end

      it "disallows URI which points to unretrievable content" do
        disallow_uri(unretrievable_http_url)
      end

      it "disallows URI which scheme is different than http or https, \
          despite :scheme option value" do
        disallow_uri(retrievable_ssh_url)
      end
    end
  end

  def allow_uri(uri_string)
    uri = Addressable::URI.parse(uri_string)
    retval = subject.match?(uri)
    expect(retval).to be(true)
  end

  def disallow_uri(uri_string)
    uri = Addressable::URI.parse(uri_string)
    retval = subject.match?(uri)
    expect(retval).to be(false)
  end
end
