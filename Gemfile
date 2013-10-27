source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.0.0'

# Includes fix to enable use of Strong Parameters
gem 'rails-api', git: 'https://github.com/rails-api/rails-api.git', branch: 'master'

gem 'oops', :path => "../oops/"
gem 'xibit', :path => "../xibit/"

gem 'require_all'
gem 'cancan'

# To use ActiveModel has_secure_password
gem 'bcrypt-ruby', '3.0.1'

# gem 'attr_encrypted'

group :development, :test do
  gem 'sqlite3'
  gem 'rspec-rails', '2.13.1'
end

group :test do
  gem 'selenium-webdriver', '2.35.1'
  gem 'capybara', '2.1.0'
  gem 'factory_girl_rails', "~> 4.0"
end

group :production do
  gem 'pg', '0.15.1'
  gem 'rails_12factor', '0.0.2'
end
