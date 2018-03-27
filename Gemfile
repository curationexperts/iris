source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.2'
gem 'darlingtonia'
gem 'devise'
gem 'devise-guests', '~> 0.6'
gem 'geo_works', github: 'samvera-labs/geo_works'
gem 'hydra-role-management'
gem 'hyrax', '1.0.5'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.5'
# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'loofah', '~> 2.2', '>= 2.2.1'
gem 'pg', '~> 0.18'
# Use Puma as the app server
gem 'puma', '~> 3.0'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 5.0.6'
gem 'rsolr', '>= 1.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
gem 'sidekiq'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Turbolinks makes navigating your web application faster. Read more: https://github.com/turbolinks/turbolinks
gem 'turbolinks', '~> 5'
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 3.0'
# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

group :development do
  gem 'listen', '~> 3.0.5'
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
end

group :development, :test do
  gem 'bixby' # bixby == the hydra community's rubocop rules
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug', platform: :mri
  gem 'capistrano'
  gem 'capistrano-bundler', '~> 1.3'
  gem 'capistrano-ext'
  gem 'capistrano-passenger'
  gem 'capistrano-rails'
  gem 'capistrano-sidekiq', '~> 0.20.0'
  gem 'database_cleaner'
  gem 'fcrepo_wrapper'
  gem 'rspec-rails'
  gem 'solr_wrapper', '>= 0.3'
end

group :test do
  gem 'coveralls', require: false
end
