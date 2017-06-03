require 'spec_helper'

class Post
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  attr_accessor :url
end

RSpec.describe UrlValidator do

  let(:post) { Post.new }
  after do
    Post.clear_validators!
  end

  context 'when url field is empty' do
    it 'fails with default message' do
      Post.validates_url_of :url

      post.url = ''
      expect(post).to_not be_valid
      expect(post.errors.first).to eq([:url, 'is not a valid URL'])
    end

    it 'fails for nil values' do
      Post.validates_url_of :url

      post.url = nil
      expect(post).to_not be_valid
      expect(post.errors.first).to eq([:url, 'is not a valid URL'])
    end

    it 'pass if accept nil values' do
      Post.validates_url_of(:url, allow_nil: true)
      post.url = nil
      expect(post).to be_valid
    end

    it 'pass if accept blank values' do
      Post.validates_url_of(:url, allow_blank: true)
      post.url = ''
      expect(post).to be_valid
    end
  end

  context 'when url is present' do
    before do
      Post.validates_url_of :url
    end

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
      it 'accept valid url: #{url}' do
        post.url = url
        expect(post).to be_valid
        expect(post.errors.count).to eq(0)
      end
    end

    invalid_urls.each do |url|
      it 'reject invalid url: #{url}' do
        post.url = url
        expect(post).to_not be_valid
      end
    end
  end

  context 'options for \'path\'' do
    context 'when value is true' do
      it 'check for path presence' do
        post.url = 'http://example.com/some/path'
        Post.validates_url_of :url, path: true
        expect(post).to be_valid
      end

      it 'reject missing path' do
        post.url = 'http://example.com/'
        Post.validates_url_of :url, path: true
        expect(post).to_not be_valid
      end
    end

    context 'when value is false' do
      it 'check for path ausence' do
        post.url = 'http://example.com/some/path'
        Post.validates_url_of :url, path: false
        expect(post).to_not be_valid
      end

      it 'reject path presence' do
        post.url = 'http://example.com/'
        Post.validates_url_of :url, path: false
        expect(post).to be_valid
      end
    end

    context 'when value is a regexp' do
      it 'check for path match' do
        post.url = 'http://example.com/some/path'
        Post.validates_url_of :url, path: /path/
        expect(post).to be_valid
      end

      it 'reject missing path' do
        post.url = 'http://example.com/'
        Post.validates_url_of :url, path: /notfound/
        expect(post).to_not be_valid
      end
    end
  end

  context 'options for \'query\'' do
    context 'when value is true' do
      it 'check for query presence' do
        post.url = 'http://example.com/?q=query'
        Post.validates_url_of :url, query: true
        expect(post).to be_valid
      end

      it 'reject missing query' do
        post.url = 'http://example.com/'
        Post.validates_url_of :url, query: true
        expect(post).to_not be_valid
      end
    end

    context 'when value is false' do
      it 'check for query ausence' do
        post.url = 'http://example.com/?q=query'
        Post.validates_url_of :url, query: false
        expect(post).to_not be_valid
      end

      it 'reject query presence' do
        post.url = 'http://example.com/'
        Post.validates_url_of :url, query: false
        expect(post).to be_valid
      end
    end
  end

  context 'options for \'fragment\'' do
    context 'when value is true' do
      it 'check for fragment presence' do
        post.url = 'http://example.com/#fragment'
        Post.validates_url_of :url, fragment: true
        expect(post).to be_valid
      end

      it 'reject missing fragment' do
        post.url = 'http://example.com/'
        Post.validates_url_of :url, fragment: true
        expect(post).to_not be_valid
      end
    end

    context 'when value is false' do
      it 'check for fragment ausence' do
        post.url = 'http://example.com/#fragment'
        Post.validates_url_of :url, fragment: false
        expect(post).to_not be_valid
      end

      it 'reject fragment presence' do
        post.url = 'http://example.com/'
        Post.validates_url_of :url, fragment: false
        expect(post).to be_valid
      end
    end
  end

end
