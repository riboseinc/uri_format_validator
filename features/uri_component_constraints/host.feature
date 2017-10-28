Feature: Host component constraints
  Scenario: By default, accept every valid URI
    Given a file named "test_example_model.rb" with:
      """ruby
      require "active_model"
      require "uri_format_validator"

      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri: true
      end

      object = ExampleModel.new

      object.uri = "http://example.com"
      puts object.valid?

      # IPv4 localhost
      object.uri = "https://127.0.0.1/example/path"
      puts object.valid?

      # IPv6 localhost
      object.uri = "https://[::1]/example/path"
      puts object.valid?

      # Hierarchical URI with authority component empty
      object.uri = "file:///dev/null"
      puts object.valid?

      # Non-hierarchical URI
      object.uri = "urn:ISSN:0167-6423"
      puts object.valid?
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

  Scenario: When host option is a string, it specifies the only allowed host
    Given a file named "test_example_model.rb" with:
      """ruby
      require "active_model"
      require "uri_format_validator"

      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri: { host: "example.com" }
      end

      object = ExampleModel.new

      object.uri = "http://example.com"
      puts object.valid?

      object.uri = "ssh://admin:admin1@example.com:22/protected"
      puts object.valid?

      object.uri = "http://subdomain.example.com"
      puts object.valid?

      # IP-based URI
      object.uri = "https://127.0.0.1/example/path"
      puts object.valid?

      # Hierarchical URI with authority component empty
      object.uri = "file:///dev/null"
      puts object.valid?

      # Non-hierarchical URI
      object.uri = "urn:ISSN:0167-6423"
      puts object.valid?
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      true
      true
      false
      false
      false
      false
      """

  Scenario: When host option is a regular expression, it specifies a pattern for allowed hosts
   Given a file named "test_example_model.rb" with:
      """ruby
      require "active_model"
      require "uri_format_validator"

      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri: { host: /\.example\./ }
      end

      object = ExampleModel.new

      object.uri = "http://www.example.com"
      puts object.valid?

      object.uri = "http://example.com"
      puts object.valid?

      object.uri = "ssh://admin:admin1@sub.domains.example.test:22/protected"
      puts object.valid?

      # Hierarchical URI with authority component empty
      object.uri = "file:///dev/null"
      puts object.valid?

      # Non-hierarchical URI
      object.uri = "urn:ISSN:0167-6423"
      puts object.valid?
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      true
      false
      true
      false
      false
      """
  Scenario: When host option is an array, it specifies a set of allowed hosts
    Given a file named "test_example_model.rb" with:
      """ruby
      require "active_model"
      require "uri_format_validator"

      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri: { host: %w[example.com 127.0.0.1] }
      end

      object = ExampleModel.new

      object.uri = "http://example.com"
      puts object.valid?

      object.uri = "http://subdomain.example.com"
      puts object.valid?

      # IP-based URI
      object.uri = "https://127.0.0.1/example/path"
      puts object.valid?

      # Hierarchical URI with authority component empty
      object.uri = "file:///dev/null"
      puts object.valid?

      # Non-hierarchical URI
      object.uri = "urn:ISSN:0167-6423"
      puts object.valid?
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      true
      false
      true
      false
      false
      """

  Scenario: IPv6 hosts need to be specified without surrounding brackets
    Given a file named "test_example_model.rb" with:
      """ruby
      require "active_model"
      require "uri_format_validator"

      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri: { host: "::1" }
      end

      object = ExampleModel.new

      object.uri = "https://[::1]/example/path"
      puts object.valid?
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      true
      """

  Scenario: A domain and the IP address it resolves to are considered to be different hosts
    Given a file named "test_example_model.rb" with:
      """ruby
      require "active_model"
      require "uri_format_validator"

      class ExampleModel
        include ActiveModel::Validations

        attr_accessor :uri
        validates :uri, uri: { host: "localhost" }
      end

      object = ExampleModel.new

      object.uri = "https://localhost/example/path"
      puts object.valid?

      object.uri = "https://127.0.0.1/example/path"
      puts object.valid?

      object.uri = "https://[::1]/example/path"
      puts object.valid?
      """

    When I run `ruby test_example_model.rb`

    Then it should pass with exactly:
      """
      true
      false
      false
      """
