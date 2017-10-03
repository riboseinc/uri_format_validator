# (c) Copyright 2017 Ribose Inc.
#

require "simplecov"
SimpleCov.start

require "codecov"
SimpleCov.formatter = SimpleCov::Formatter::Codecov

require "bundler"
Bundler.require :default, :development
# require "uri_format_validator"

Dir[File.expand_path "../support/**/*.rb", __FILE__].sort.each { |f| require f }

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
