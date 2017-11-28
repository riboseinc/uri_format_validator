# (c) Copyright 2017 Ribose Inc.
#

require "spec_helper"

RSpec.describe UriFormatValidator::Reacher do
  let(:url_s) { "http://host.example.test/resource" }

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

  def retval_for(url)
    instance = described_class.new(Addressable::URI.parse(url))
    bound_method = subject.bind(instance)
    bound_method.call
  end
end
