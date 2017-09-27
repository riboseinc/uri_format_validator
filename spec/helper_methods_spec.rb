# (c) Copyright 2017 Ribose Inc.
#

require "spec_helper"

describe ActiveModel::Validations::HelperMethods do
  let(:post) { Post.new }

  it "provides alternative, old-fashioned way to set validations" do
    Post.validates_uri_format_of :url

    post.url = "http://google"
    expect(post).not_to be_valid
    post.url = "http://google.com"
    expect(post).to be_valid
  end
end
