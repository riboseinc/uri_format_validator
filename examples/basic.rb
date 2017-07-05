class MyModel
  validates :favourite_website_url, url: true, resolvability: :retrievable
  validates :resume_cv_url, url: true, resolvability: :reachable
end
