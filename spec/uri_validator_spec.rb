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
    context "when unspecified" do
      it "allows URI with http scheme which points to retrievable content" do
        post.url = "http://example.com/relative/path"
        stub_request(:head, post.url).to_return(status: 200)
        Post.validates :url, uri: { scheme: :all }
        expect(post).to be_valid
      end

      it "allows URI with https scheme which points to retrievable content" do
        post.url = "https://example.com/relative/path"
        stub_request(:head, post.url).to_return(status: 200)
        Post.validates :url, uri: { scheme: :all }
        expect(post).to be_valid
      end

      it "allows URI which points to unretrievable content" do
        post.url = "http://example.com/relative/path"
        stub_request(:head, post.url).to_return(status: 404)
        Post.validates :url, uri: { scheme: :all }
        expect(post).to be_valid
      end

      it "allows URI which scheme is different than http or https" do
        pending "The list of allowed schemes is broken, see issue #62"
        post.url = "ssh://git@github.com:riboseinc/uri_format_validator.git"
        stub_request(:head, post.url).to_return(status: 200)
        Post.validates :url, uri: { scheme: :all }
        expect(post).to be_valid
      end
    end

    context "when is false" do
      it "allows URI with http scheme which points to retrievable content" do
        post.url = "http://example.com/relative/path"
        stub_request(:head, post.url).to_return(status: 200)
        Post.validates :url, uri: { retrievable: false, scheme: :all }
        expect(post).to be_valid
      end

      it "allows URI with https scheme which points to retrievable content" do
        post.url = "https://example.com/relative/path"
        stub_request(:head, post.url).to_return(status: 200)
        Post.validates :url, uri: { retrievable: false, scheme: :all }
        expect(post).to be_valid
      end

      it "allows URI which points to unretrievable content" do
        post.url = "http://example.com/relative/path"
        stub_request(:head, post.url).to_return(status: 404)
        Post.validates :url, uri: { retrievable: false, scheme: :all }
        expect(post).to be_valid
      end

      it "allows URI which scheme is different than http or https" do
        pending "The list of allowed schemes is broken, see issue #62"
        post.url = "ssh://git@github.com:riboseinc/uri_format_validator.git"
        stub_request(:head, post.url).to_return(status: 200)
        Post.validates :url, uri: { retrievable: false, scheme: :all }
        expect(post).to be_valid
      end
    end

    context "when is true" do
      it "allows URI with http scheme which points to retrievable content" do
        post.url = "http://example.com/relative/path"
        stub_request(:head, post.url).to_return(status: 200)
        Post.validates :url, uri: { retrievable: true, scheme: :all }
        expect(post).to be_valid
      end

      it "allows URI with https scheme which points to retrievable content" do
        post.url = "https://example.com/relative/path"
        stub_request(:head, post.url).to_return(status: 200)
        Post.validates :url, uri: { retrievable: true, scheme: :all }
        expect(post).to be_valid
      end

      it "disallows URI which points to unretrievable content" do
        post.url = "http://example.com/relative/path"
        stub_request(:head, post.url).to_return(status: 404)
        Post.validates :url, uri: { retrievable: true, scheme: :all }
        expect(post).to be_invalid
      end

      it "disallows URI which scheme is different than http or https, \
          despite :scheme option value" do
        post.url = "ssh://git@github.com:riboseinc/uri_format_validator.git"
        stub_request(:head, post.url).to_return(status: 200)
        Post.validates :url, uri: { retrievable: true, scheme: :all }
        expect(post).to be_invalid
      end
    end
  end
end
