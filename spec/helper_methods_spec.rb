# (c) Copyright 2017 Ribose Inc.
#

require "spec_helper"

describe UriFormatValidator::Validators::HelperMethods do
  let(:post) { Post.new }

  it "provides alternative, old-fashioned way to set validations" do
    # Validating URLs requires additional constraints.  Not all valid URIs
    # with http(s) scheme set are valid URLs.  We used to have a RegExp
    # for that, but it has been proven to be way too limited.
    #
    # Disabling for now, these tests may (should be) reintroduced later.
    pending "General URL-specific specs have been disabled"
    Post.validates_uri_format_of :url

    post.url = "http://google"
    expect(post).not_to be_valid
    post.url = "http://google.com"
    expect(post).to be_valid
  end
end
