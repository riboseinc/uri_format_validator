Feature: Ensuring that content pointed by URL is retrievable
  Background:
    Given a file named "test_example_model.rb" with:
      """ruby
      require "active_model"
      require "uri_format_validator"
      require_relative "./example_model"

      require "webmock"
      include WebMock::API

      WebMock.enable!

      WebMock.stub_request(:any, "www.example.com/200").to_return(status: 200)
      WebMock.stub_request(:any, "www.example.com/404").to_return(status: 404)

      object = ExampleModel.new

      object.uri = "http://www.example.com/200"
      puts object.valid?

      object.uri = "http://www.example.com/404"
      puts object.valid?
      """

  Scenario: By default, all valid URIs are accepted
    And a file named "example_model.rb" with:
      """ruby
      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri: true
      end
      """
    When I run `ruby test_example_model.rb`
    Then it should pass with exactly:
      """
      true
      true
      """

  Scenario: When retrievable option is specified, a response to HEAD request made to that URL must have 2xx status code
    And a file named "example_model.rb" with:
      """ruby
      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri: {retrievable: true}
      end
      """
    When I run `ruby test_example_model.rb`
    Then it should pass with exactly:
      """
      true
      false
      """
