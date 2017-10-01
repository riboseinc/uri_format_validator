# (c) Copyright 2017 Ribose Inc.
#

require "spec_helper"

RSpec.describe UriFormatValidator::Reacher do
  let(:url_s) { "http://host.example.test/resource" }
  let(:url) { URI(url_s) }

  it "is initialized with an URL" do
    expect(described_class.new(url)).to be_instance_of(described_class)
  end
end
