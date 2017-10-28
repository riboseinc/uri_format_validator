# (c) Copyright 2017 Ribose Inc.
#

require "spec_helper"

RSpec.describe UriFormatValidator::Validators::UriValidator do
  let(:post) { Post.new }

  context "when url is present" do
    before do
      Post.validates :url, uri: true
    end

    valid_urls = [
      "http://google.com",
      "https://google.com",
      "http://www.google.com",
      "http://goo-gle.com",
      "http://1234.com",
      "http://google.uk",
    ]
    invalid_urls = [
      "google.com",
      "http://google",
      "http://google.looooongltd",
    ]

    valid_urls.each do |url|
      it "accept valid url: #{url}" do
        post.url = url
        expect(post).to be_valid
        expect(post.errors.count).to eq(0)
      end
    end

    invalid_urls.each do |url|
      it "reject invalid url: #{url}" do
        # Validating URLs requires additional constraints.  Not all valid URIs
        # with http(s) scheme set are valid URLs.  We used to have a RegExp
        # for that, but it has been proven to be way too limited.
        #
        # Disabling for now, these tests may (should be) reintroduced later.
        pending "General specs for URL validation have been disabled"
        post.url = url
        expect(post).to_not be_valid
      end
    end

    it "reject malformed strings" do
      Post.validates :url, uri: true
      post.url = " http://google.com "
      expect(post).to_not be_valid
    end
  end

  describe ":host option" do
    let(:http_uri) { "http://example.com/relative/path" }
    let(:https_uri) { "https://another.example.com/different/path" }
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
      end

      it "disallows URIs which host subcomponent is different than specified \
          string, even if it's a subdomain of that string" do
        disallow_uri(https_uri)
        disallow_uri(http_ipv6_uri)
      end

      it "disallows URIs which host subcomponent is missing" do
        disallow_uri(local_file_uri)
        disallow_uri(urn)
      end
    end

    context "when is a regular expression" do
      let(:validation_options) { { host: /\.example\.com$/ } }

      it "allows URIs which host subcomponent matches the regular expression" do
        allow_uri(https_uri)
      end

      it "disallows URIs which host subcomponent does not match the regular \
          expression" do
        disallow_uri(http_uri)
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
        allow_uri(http_ipv6_uri)
      end

      it "disallows URIs which host subcomponent matches neither element of \
          the specified array" do
        disallow_uri(https_uri)
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
    let(:retrievable_ssh_url) { "ssh://git@github.com:riboseinc/some_repo.git" }

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
        pending "The list of allowed schemes is broken, see issue #62"
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
        pending "The list of allowed schemes is broken, see issue #62"
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
    post.url = uri_string
    expect(post).to be_valid
  end

  def disallow_uri(uri_string)
    post.url = uri_string
    expect(post).to be_invalid
    expect(post.errors[:url]).to be_present
  end
end
