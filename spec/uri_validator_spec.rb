# (c) Copyright 2017 Ribose Inc.
#

require "spec_helper"

RSpec.describe UriFormatValidator::Validators::UriValidator do
  let(:post) { Post.new }
  let(:minimal_valid_initializer_args) { { attributes: :whatever } }

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

  describe "#build_white_and_black_lists" do
    subject { validator.method(:build_white_and_black_lists) }
    let(:validator) { described_class.new(minimal_valid_initializer_args) }

    context "when options argument is a hash which does not include accept nor \
             reject keys" do
      let(:options) { { some: :constraints, defined: :here } }

      it "builds one-element accept list basing on these options" do
        subject.call options
        expect(validator.accept_list.size).to eq(1)
        expect(validator.accept_list.first.options).to eq(options)
      end

      it "builds empty reject list" do
        subject.call options
        expect(validator.reject_list).to be_empty
      end
    end

    context "when options argument is a hash which includes accept key but not \
             reject key" do
      let(:options) do
        {
          accept: [{ some: :constraints }, { defined: :here }],
        }
      end

      it "builds accept list basing on accept value" do
        subject.call options
        expect(validator.accept_list.size).to eq(2)
        expect(validator.accept_list[0].options).to eq(some: :constraints)
        expect(validator.accept_list[1].options).to eq(defined: :here)
      end

      it "builds empty reject list" do
        subject.call options
        expect(validator.reject_list).to be_empty
      end
    end

    context "when options argument is a hash which includes reject key but not \
             accept key" do
      let(:options) do
        {
          reject: [{ some: :constraints }, { defined: :here }],
        }
      end

      it "builds allow-all accept list" do
        subject.call options
        expect(validator.accept_list.size).to eq(1)
        expect(validator.accept_list[0].options).
          to eq(described_class::ALLOW_ALL_OPTION_HASH)
      end

      it "builds reject list basing on reject value" do
        subject.call options
        expect(validator.reject_list.size).to eq(2)
        expect(validator.reject_list[0].options).to eq(some: :constraints)
        expect(validator.reject_list[1].options).to eq(defined: :here)
      end
    end

    context "when options argument is a hash which includes both accept and \
             reject keys" do
      let(:options) do
        {
          accept: [{ some: :constraints }, { defined: :here }],
          reject: [{ other: :constraints }, { defined: :here }],
        }
      end

      it "builds empty reject list" do
        subject.call options
        expect(validator.accept_list.size).to eq(2)
        expect(validator.accept_list[0].options).to eq(some: :constraints)
        expect(validator.accept_list[1].options).to eq(defined: :here)
      end

      it "builds accept list basing on accept value" do
        subject.call options
        expect(validator.reject_list.size).to eq(2)
        expect(validator.reject_list[0].options).to eq(other: :constraints)
        expect(validator.reject_list[1].options).to eq(defined: :here)
      end
    end
  end

  describe "#fits_accept_and_reject_lists?" do
    subject { validator.method(:fits_accept_and_reject_lists?) }
    let(:validator) { described_class.new(minimal_valid_initializer_args) }
    let(:accept_list) { [] }
    let(:reject_list) { [] }

    before do
      allow(validator).to receive(:accept_list).and_return(accept_list)
      allow(validator).to receive(:reject_list).and_return(reject_list)
    end

    it "returns true if the passed block evaluates to truthy value for \
        at least one item in the accept list and none in the reject list" do
      accept_list.push(1, 2, 3)
      reject_list.push(4, 6)
      expect(subject.call(&:odd?)).to be(true)
    end

    it "returns false if the passed block evaluates to truthy value for \
        at least one item in the the reject list" do
      accept_list.push(1, 2, 3)
      reject_list.push(4, 5, 6)
      expect(subject.call(&:odd?)).to be(false)
    end

    it "returns false if the passed block evaluates to truthy value for \
        neither item in the accept list" do
      accept_list.push(1, 2, 3)
      reject_list.push(4, 5, 6)
      expect(subject.call(&:negative?)).to be(false)
    end
  end
end
