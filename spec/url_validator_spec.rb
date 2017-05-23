require "spec_helper"

class Post
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  attr_accessor :url

  validates :url, url: true
end

RSpec.describe UrlValidator do
  let(:post) {Post.new}

  context "when url field is empty" do
    it "fails with default message" do
      post.url = ''
      expect(post).to_not be_valid
      expect(post.errors.first).to eq([:url, 'is not a valid URL'])
    end

    it "fails for nil values" do
      post.url = nil
      expect(post).to_not be_valid
      expect(post.errors.first).to eq([:url, 'is not a valid URL'])
    end
  end

  context "when url is present" do
    valid_urls = [
      'http://google.com',
      'https://google.com',
      'http://www.google.com',
      'http://goo-gle.com',
      'http://1234.com',
      'http://google.uk'
    ]
    invalid_urls = [
      'google.com',
      'http://google',
      'http://google.looooongltd'
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
        post.url = url
        expect(post).to_not be_valid
      end
    end

  end
end
