Feature: Scheme component constraints
  Background:
    Given a file named "test_example_model.rb" with:
      """ruby
      require "active_model"
      require "uri_format_validator"
      require_relative "./example_model"

      object = ExampleModel.new

      object.uri = "http://example.com"
      puts object.valid?

      object.uri = "https://example.com"
      puts object.valid?

      object.uri = "telnet://example.com"
      puts object.valid?

      object.uri = "ssh://example.com"
      puts object.valid?

      object.uri = "nonexisting://example.com"
      puts object.valid?
      """

  Scenario: By default, accept every valid URI
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

  Scenario: When sheme option is a string, it specifies the only allowed scheme
    And a file named "example_model.rb" with:
      """ruby
      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri: { scheme: "http" }
      end
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      true
      false
      false
      false
      false
      """

  Scenario: When sheme option is an array, it specifies allowed schemes
    And a file named "example_model.rb" with:
      """ruby
      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri: { scheme: %w[telnet ssh http] }
      end
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      true
      false
      true
      true
      false
      """
