source 'https://rubygems.org'

ruby '2.0.0'

# Common
gem 'mongoid'

# Service
gem 'faraday'
gem 'faraday_middleware'
gem 'faraday-cookie_jar'
gem 'hashie'
gem 'typhoeus'

# Web
gem 'sinatra', require: 'sinatra/base'
gem 'sinatra-contrib'
gem 'sinatra-asset_pipeline', path: '../sinatra-asset_pipeline'
gem "rack_csrf", require: "rack/csrf"
gem "rack-protection"
gem 'puma'

# Frontend
gem 'haml'
gem 'sass'
gem 'sprockets-sass'
gem 'coffee-script'
gem 'uglifier'
gem 'compass'
gem 'bootstrap-sass', require: false

gem 'pry', require: false

group :development, :test do
  gem 'dotenv'
  gem 'pry'
  gem 'better_errors'
  gem 'binding_of_caller'
end

group :test do
  gem 'rspec'
  gem 'rack-test', github: 'brynary/rack-test'
end
