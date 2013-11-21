source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'
gem "rack"

# Includes fix to enable use of Strong Parameters
gem 'rails-api', git: 'https://github.com/rails-api/rails-api.git', branch: 'master'

gem 'oops', :path => "../oops/"
gem 'xibit', :path => "../xibit/"

gem 'require_all'
gem 'pundit'
# Github master supports Rails 4
gem 'validates_existence', git: 'https://github.com/perfectline/validates_existence.git', branch: 'master'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '3.0.1'

# gem 'attr_encrypted'

group :development, :test do
  gem 'sqlite3'
end

group :test do
  gem 'selenium-webdriver', '2.35.1'
  gem 'capybara', '2.1.0'
  gem 'rspec-rails'
  gem 'factory_girl_rails', "~> 4.0"
  gem 'shoulda-matchers'
  gem 'json_spec'
  gem 'timecop'
  gem 'simplecov', :require => false
end

group :production do
  gem 'pg', '0.15.1'
  gem 'rails_12factor', '0.0.2'
end

