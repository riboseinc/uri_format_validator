Feature: Authority component constraints
  Background:
    Given a file named "test_example_model.rb" with:
      """ruby
      require "active_model"
      require "uri_format_validator"
      require_relative "./example_model"

      object = ExampleModel.new

      object.uri = "http://example.com/path"
      puts object.valid?

      object.uri = "http://example.test/path"
      puts object.valid?

      object.uri = "example.com/path"
      puts object.valid?

      object.uri = "/path"
      puts object.valid?

      object.uri = "https://www.google.pl/search?q=example"
      puts object.valid?
      """

  Scenario: By default, it accepts only absolute URIs with scheme present
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
      false
      false
      true
      """

  Scenario: When authority option is an array, it limits allowed authorities to array elements
    And a file named "example_model.rb" with:
      """ruby
      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri_format: { authority: %w[example.com example.test] }
      end
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      true
      true
      false
      false
      false
      """

  Scenario: When authority option is a regular expression, it limits allowed authorities to array elements
    And a file named "example_model.rb" with:
      """ruby
      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri_format: { authority: /(\.|^)example\.(com|test)$/ }
      end
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      true
      true
      false
      false
      false
      """

  Scenario: When authority option is a false, it allows relative URIs only
    And a file named "example_model.rb" with:
      """ruby
      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri_format: { authority: false }
      end
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      true
      true
      true
      false
      true
      """
