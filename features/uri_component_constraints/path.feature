Feature: Path component constraints
  Background:
    Given a file named "test_example_model.rb" with:
      """ruby
      require_relative "./example_model"
      object = ExampleModel.new

      object.uri = "http://example.com"
      puts object.valid?

      object.uri = "http://example.com/"
      puts object.valid?

      object.uri = "http://example.com/things"
      puts object.valid?

      object.uri = "http://example.com/app/things"
      puts object.valid?
      """

  Scenario: By default, accept URIs with or without path
    Given a file named "example_model.rb" with:
      """ruby
      require "active_model"
      require "uri_format_validator"

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
      true
      true
      """

  Scenario: When path option is set to true, the path component is required
    Given a file named "example_model.rb" with:
      """ruby
      require "active_model"
      require "uri_format_validator"

      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri_format: { path: true }
      end
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      false
      false
      true
      true
      """

  @todo
  # Fails, is it because of bug?
  Scenario: When path option is set to false, the path component must be empty
    Given a file named "example_model.rb" with:
      """ruby
      require "active_model"
      require "uri_format_validator"

      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri_format: { path: false }
      end
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      true
      true
      false
      false
      """

  Scenario: When path option is a regular expression, the path component must match it
    Given a file named "example_model.rb" with:
      """ruby
      require "active_model"
      require "uri_format_validator"

      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri_format: { path: %r[^/app/] }
      end
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      false
      false
      false
      true
      """
