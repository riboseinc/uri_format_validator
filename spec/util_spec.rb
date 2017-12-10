# (c) Copyright 2017 Ribose Inc.
#

require "spec_helper"

RSpec.describe UriFormatValidator::Util do
  describe "#parse_host" do
    subject { described_class.method :parse_host }

    it "returns nil for nil or blank string" do
      expect(subject.(nil)).to be(nil)
      expect(subject.(" ")).to be(nil)
    end

    it "returns an IPAddr for strings which look like IPv4 addresses" do
      expect(subject.("127.0.0.1")).
        to be_kind_of(IPAddr) & eq("127.0.0.1")
    end

    it "returns an IPAddr for strings which look like IPv6 addresses" do
      expect(subject.("::1")).
        to be_kind_of(IPAddr) & eq("::1")
      expect(subject.("[::1]")).
        to be_kind_of(IPAddr) & eq("::1")
      expect(subject.("1:2:3:4:5:6:7:8")).
        to be_kind_of(IPAddr) & eq("1:2:3:4:5:6:7:8")
      expect(subject.("[1:2:3:4:5:6:7:8]")).
        to be_kind_of(IPAddr) & eq("1:2:3:4:5:6:7:8")
    end

    it "returns unmodified argument for non-blank strings which don't \
        represent IP addresses" do
      expect(subject.("localhost")).
        to be_kind_of(String) & eq("localhost")
      expect(subject.("www.example.test")).
        to be_kind_of(String) & eq("www.example.test")
      expect(subject.("whatever")).
        to be_kind_of(String) & eq("whatever")
    end
  end
end
