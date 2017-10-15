# (c) Copyright 2017 Ribose Inc.
#

require "spec_helper"

RSpec.describe UriFormatValidator::Reacher do
  let(:url_s) { "http://host.example.test/resource" }

  let(:google_ip_v4) { "216.58.209.46" }
  let(:google_ip_v6) { "2A00:1450:401B:800::200E" }
  let(:google_com) { "google.com" }
  let(:gibberish_com) { "asdfasdfasdfas.asdfjaasdfads.asdfasdfafsdsd.com" }

  it "is initialized with an URL" do
    object = described_class.new(double(Addressable::URI))
    expect(object).to be_instance_of(described_class)
  end

  describe "#retrievable?" do
    subject { described_class.instance_method :retrievable? }

    it "returns true when the response is HTTP 2xx" do
      stub_request(:head, url_s).to_return(status: 200)
      expect(retval_for(url_s)).to be(true)
    end

    it "returns false when the response is HTTP 4xx" do
      stub_request(:head, url_s).to_return(status: 403)
      expect(retval_for(url_s)).to be(false)
    end

    it "returns false when the response is HTTP 5xx" do
      stub_request(:head, url_s).to_return(status: 500)
      expect(retval_for(url_s)).to be(false)
    end

    it "returns false for URL schemes other than http or https" do
      expect(retval_for("ssh://host.example.test/resource")).to be(false)
    end
  end

  describe "#resolvable?" do
    subject { described_class.instance_method :resolvable? }

    it "returns true for an IPv4 address" do
      expect(retval_for("http://127.0.0.1/path")).to be(true)
      expect(retval_for("http://#{google_ip_v4}/path")).to be(true)
    end

    it "returns true for an IPv6 address" do
      expect(retval_for("http://[::1]/path")).to be(true)
      expect(retval_for("http://[::]/path")).to be(true)
      expect(retval_for("http://[#{google_ip_v6}]/path")).to be(true)
    end

    it "returns true for a resolvable domain" do
      expect(retval_for("http://#{google_com}/path")).to be(true)
    end

    it "returns false for a non-resolvable domain" do
      expect(retval_for("http://#{gibberish_com}/path")).to be(false)
    end

    it "returns true when domain is missing" do
      expect(retval_for("file:///dev/null")).to be(true)
    end
  end

  def retval_for(url)
    instance = described_class.new(Addressable::URI.parse(url))
    bound_method = subject.bind(instance)
    bound_method.call
  end
end
