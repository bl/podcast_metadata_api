source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'
# rails api framework
gem 'rails-api', '~> 0.4'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# Use ActiveModel::Serializers to serialize ActiveModel/ActiveRecord objects
# use version 0.10.x
gem 'active_model_serializers', git: 'https://github.com/rails-api/active_model_serializers.git'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'
# used for reading audio file metadata tags
gem 'taglib-ruby'
# Carrierwave used for uploading podcast audio data
gem 'carrierwave'
# Puma used for hosting rails server
#gem 'puma'

# Web specific gems
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# bootstrap HTML, CSS, JS Framework used for client interface
gem 'bootstrap-sass'
# Use jquery as the JavaScript library
gem 'jquery-rails'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # debugging environment more sophisticated than byebug
  gem 'pry-rails'
  # replacement for fixtures for test data
  gem 'factory_girl_rails'
  # Used for generating fake date
  gem 'ffaker'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  gem 'minitest-reporters', '1.0.5'
  gem 'mini_backtrace',     '0.1.3'
  gem 'guard-minitest',     '2.3.1'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

