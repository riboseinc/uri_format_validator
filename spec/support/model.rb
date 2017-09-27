class Post
  include ActiveModel::Validations
  include ActiveModel::Validations::Callbacks
  attr_accessor :url
end

RSpec.configure do |config|
  config.after(:example) do
    Post.clear_validators!
  end
end
