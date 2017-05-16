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
      post.url = 'http://google'
      expect(post.valid?).to be false
      expect(post.errors.first).to eq([:url, 'is not a valid URL'])
    end
  end

  context "when url is present" do
    it "accept valid urls" do
      valid_urls = [
        'http://google.com',
        'https://google.com',
        'http://www.google.com',
        'http://goo-gle.com',
        'http://1234.com',
        'http://google.uk'
      ]

      valid_urls.each do |url|
        post.url = url
        expect(post.valid?).to be true
        expect(post.errors.count).to eq(0)
      end
    end

    it "reject invalid urls" do
      invalid_urls = [
        'google.com',
        'http://google',
        'http://google.looooongltd'
      ]

      invalid_urls.each do |url|
        post.url = url
        expect(post.valid?).to be false
      end
    end

  end
end
