class MyModel
  validates :favourite_website_url, url: { resolvability: :retrievable }
  validates :resume_cv_url, url: { resolvability: :reachable }
  validates :friend_website_url, url: { scheme: %w[http https ftp] }
end
