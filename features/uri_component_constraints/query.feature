Feature: Query component constraints
  Background:
    Given a file named "test_example_model.rb" with:
      """ruby
      require "active_model"
      require "uri_format_validator"
      require_relative "./example_model"

      object = ExampleModel.new

      object.uri = "http://example.com"
      puts object.valid?

      object.uri = "http://example.com/?a=b"
      puts object.valid?
      """

  Scenario: By default, accept URIs with or without query
    And a file named "example_model.rb" with:
      """ruby
      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri_format: true
      end
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      true
      true
      """

  Scenario: When query option is set to true, the query component is required
    And a file named "example_model.rb" with:
      """ruby
      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri_format: { query: true }
      end
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      false
      true
      """

  Scenario: When query option is set to false, the query component must be empty
    And a file named "example_model.rb" with:
      """ruby
      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri_format: { query: false }
      end
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      true
      false
      """
