class MyModel
  validates :favourite_website_url, uri_format: { resolvability: :retrievable }
  validates :resume_cv_url, uri_format: { resolvability: :reachable }
  validates :friend_website_url, uri_format: { scheme: %w[http https ftp] }
end
