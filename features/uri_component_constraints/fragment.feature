Feature: Fragment component constraints
  Background:
    Given a file named "test_example_model.rb" with:
      """ruby
      require "active_model"
      require "uri_format_validator"
      require_relative "./example_model"

      object = ExampleModel.new

      object.uri = "http://example.com/path"
      puts object.valid?

      object.uri = "http://example.com/path#fragment"
      puts object.valid?
      """

  Scenario: By default, accept URIs with or without fragment
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

  Scenario: When fragment option is set to true, the fragment component is required
    And a file named "example_model.rb" with:
      """ruby
      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri_format: { fragment: true }
      end
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      false
      true
      """

  Scenario: When fragment option is set to false, the fragment component must be empty
    And a file named "example_model.rb" with:
      """ruby
      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri_format: { fragment: false }
      end
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      true
      false
      """
