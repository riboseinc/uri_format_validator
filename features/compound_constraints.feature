Feature: Compound constraints
  URI constraints can be composed by passing white and black lists in `accept`
  and `reject` options.

  If only the `accept` option is specified, a given URI is considered valid if
  and only if it matches any constraint set listed in that option.
  If only the `reject` option is specified, a given URI is considered valid if
  and only if it matches none constraint set listed in that option.
  If both `accept` and `reject` options are specified, a given URI is considered
  valid if and only if it matches any constraint set listed in `accept` option,
  and none listed in `reject` option.

  Scenario: Use `accept` option to whitelist multiple constraints
    Given a file named "test_example_model.rb" with:
      """ruby
      require "active_model"
      require "uri_format_validator"

      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri: {
          accept: [{scheme: "http"}, {host: "this.example.com"}]
        }
      end

      object = ExampleModel.new

      object.uri = "http://this.example.com/path"
      puts object.valid?

      object.uri = "ftp://this.example.com/path"
      puts object.valid?

      object.uri = "http://other.example.com/path"
      puts object.valid?

      object.uri = "ftp://other.example.com/path"
      puts object.valid?
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      true
      true
      true
      false
      """

  Scenario: Use `reject` option to blacklist multiple constraints
    Given a file named "test_example_model.rb" with:
      """ruby
      require "active_model"
      require "uri_format_validator"

      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri: {
          reject: [{scheme: "ftp"}, {host: "blacklisted.example.com"}]
        }
      end

      object = ExampleModel.new

      object.uri = "http://example.com/path"
      puts object.valid?

      object.uri = "ftp://example.com/path"
      puts object.valid?

      object.uri = "http://blacklisted.example.com/path"
      puts object.valid?

      object.uri = "ftp://blacklisted.example.com/path"
      puts object.valid?
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      true
      false
      false
      false
      """

  Scenario: Mix `accept` and `reject` options
    Given a file named "test_example_model.rb" with:
      """ruby
      require "active_model"
      require "uri_format_validator"

      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri: {
          accept: [{scheme: "https"}],
          reject: [{host: "blacklisted.example.com"}]
        }
      end

      object = ExampleModel.new

      object.uri = "https://example.com/path"
      puts object.valid?

      object.uri = "ftp://example.com/path"
      puts object.valid?

      object.uri = "https://blacklisted.example.com/path"
      puts object.valid?

      object.uri = "ftp://blacklisted.example.com/path"
      puts object.valid?
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      true
      false
      false
      false
      """
