begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new(:spec)
  task :test => :spec
  task :default => :spec
rescue LoadError => ex
end

task :env do
  require "./app"
end

task :environment => :env

desc "Open a console in the context of the app"
task :console => :env do
  require "pry"
  binding.pry
end

desc "Create a new user or update an existing one"
task :create_user, [:name, :password] => [:env] do |t,args|
  user = Sigscrape::Commands.create_or_update_user(args[:name], args[:password])
  puts "Created user '#{user.name}' with password '#{user.password}'"
end

desc "Update journey times for all users"
task :update_journeys => :env do
  Sigscrape::Models::User.all.each do |user|
    # TODO: why does this take a name?
    Sigscrape::Commands.update_user_journeys(user)
  end
end

namespace :mongoid do
  def mongoid_models
    ns = Sigscrape::Models
    ns.constants.map(&ns.method(:const_get))
      .select { |c| c.ancestors.include?(Mongoid::Document) && ! c.embedded? }
  end

  desc "Create the indexes defined on your mongoid models"
  task :create_indexes => :env do
    mongoid_models.each(&:create_indexes)
  end

  desc "Remove the indexes defined on your mongoid models without questions!"
  task :remove_indexes => :env do
    mongoid_models.each(&:collection).each(&:remove_indexes)
  end

  desc "Drops the database for the current Rails.env"
  task :drop => :env do
    Mongoid::Sessions.default.drop
  end

  desc "Drop all collections except the system collections"
  task :purge => :env do
    Mongoid.purge!
  end
end
