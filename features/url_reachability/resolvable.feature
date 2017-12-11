Feature: Ensuring that URI domain is resolvable
  Background:
    Given a file named "test_example_model.rb" with:
      """ruby
      require "active_model"
      require "uri_format_validator"
      require_relative "./example_model"

      object = ExampleModel.new

      # There is a DNS address for example.com domain
      object.uri = "http://www.example.com/"
      puts object.valid?

      # There is no DNS address for example.test domain
      object.uri = "http://www.example.test/"
      puts object.valid?

      # All IP addresses are considered resolvable
      object.uri = "http://127.0.0.1/"
      puts object.valid?
      object.uri = "http://[::]/"
      puts object.valid?

      # URLs without host name are considered resolvable
      object.uri = "file:///dev/null"
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
      true
      true
      true
      """

  Scenario: With resolvable option specified, a DNS lookup is performed for domain addresses, and these without DNS record are rejected
    And a file named "example_model.rb" with:
      """ruby
      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri: {resolvable: true}
      end
      """
    When I run `ruby test_example_model.rb`
    Then it should pass with exactly:
      """
      true
      false
      true
      true
      true
      """
