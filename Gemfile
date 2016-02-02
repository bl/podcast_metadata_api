source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'
# rails api framework
gem 'rails-api', '~> 0.4'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'

# Use SCSS for stylesheets
#gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# use railsconfig for yaml based configuration files to load environment specific settings
gem 'config'
# Use ActiveModel::Serializers to serialize ActiveModel/ActiveRecord objects
# use version 0.10.x
gem 'active_model_serializers', git: 'https://github.com/rails-api/active_model_serializers.git'
# Use ActiveModel has_secure_password
gem 'bcrypt', '~> 3.1.7'
# used for reading audio file metadata tags
gem 'taglib-ruby'
# Carrierwave used for uploading podcast audio data
# using master branch for most recent aws suppot
gem 'carrierwave', git: 'https://github.com/carrierwaveuploader/carrierwave.git'
# Puma used for hosting rails server
gem 'puma'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
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

group :production do
  # use fog-aws with carrierwave to host assets on amazon aws
  gem 'fog-aws'
end

