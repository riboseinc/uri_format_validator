# coding: utf-8

# rubocop:disable Metrics/BlockLength

lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "uri_format_validator/version"

Gem::Specification.new do |spec|
  spec.name          = "uri_format_validator"
  spec.version       = UriFormatValidator::VERSION
  spec.authors       = ["Ribose Inc."]
  spec.email         = ["open.source@ribose.com"]

  spec.summary       = "Library for validating urls in Rails"
  spec.description   = "Library for validating urls in Rails"
  spec.homepage      = "https://github.com/riboseinc/uri_format_validator"
  spec.license       = "MIT"

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.2.2"

  spec.add_runtime_dependency "activemodel", ">= 4.0.0", "< 6"
  spec.add_runtime_dependency "addressable", "~> 2.5"

  spec.add_development_dependency "aruba", "~> 0.14"
  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "cucumber", "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rubocop", "~> 0.54.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "webmock", "~> 3.0"
end
