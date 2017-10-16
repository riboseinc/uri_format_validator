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
      let(:validation_options) { { scheme: :all } }

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
      let(:validation_options) { { retrievable: false, scheme: :all } }

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
      let(:validation_options) { { retrievable: true, scheme: :all } }

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
