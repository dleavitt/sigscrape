RACK_ENV = ENV['RACK_ENV'] || :development

require "rubygems"
require "bundler"
ENV['RACK_ENV'] ||= "development"
Bundler.require :default, RACK_ENV
require "sinatra/reloader"

Dotenv.load ".env.#{ENV['RACK_ENV']}", ".env" if defined? Dotenv
Mongoid.load!("config/mongoid.yml", ENV['RACK_ENV'])
LIB_PATH = File.join(File.dirname(__FILE__), "lib", "**", "*.rb")
Dir[LIB_PATH].each(&method(:require))

class Sigscrape::App < Sinatra::Base

  register Sinatra::AssetPipeline

  use Rack::Session::Cookie, secret: ENV['SESSION_SECRET']
  use Rack::Csrf, raise: true
  set :haml, escape_html: true

  configure :development do
    register Sinatra::Reloader
    also_reload LIB_PATH

    use BetterErrors::Middleware
    BetterErrors.application_root = File.expand_path('..', __FILE__)
  end

  helpers do
    def current_user
      if session[:user_id]
        @current_user ||= Sigscrape::Models::User.find(session[:user_id])
      else
        nil
      end
    end
  end

  get "/" do
    haml current_user ? :index : :login
  end

  post "/login" do
    if user = Commands.log_in_to_site(params[:name], params[:password])
      session[:user_id] = user.id
      redirect to("/")
    else
      haml :login, login_error: true
    end
  end

  post "/logout" do
    session[:user_id] = nil
    redirect to("/")
  end
end
