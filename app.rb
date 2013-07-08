require "rubygems"
require "bundler"
ENV['RACK_ENV'] ||= "development"
Bundler.require :default, ENV['RACK_ENV']
require "yaml"

Dotenv.load ".env.#{ENV['RACK_ENV']}", ".env" if defined? Dotenv
Mongoid.load!("config/mongoid.yml", ENV['RACK_ENV'])

Dir[File.join(File.dirname(__FILE__), "lib", "**", "*.rb")].each(&method(:require))
