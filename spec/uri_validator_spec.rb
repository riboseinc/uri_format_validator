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
end
