ENV['RACK_ENV'] = 'test'

require "./app"

def fixture(name)
  File.read(File.join(File.dirname(__FILE__), 'fixtures', name))
end

def client
  Sigscrape::Services::Sigalert.new do |c|
    c.adapter :test do |stub|
      stub.post(Sigscrape::Services::Sigalert::AUTH_ENDPOINT) do
        [ 200, {'Set-Cookie' => 'a=1; b=2;'}, '{}' ]
      end

      stub.get(Sigscrape::Services::Sigalert::ROUTES_ENDPOINT) do
        [ 200, {}, fixture("get_saved_routes.json")]
      end
    end
  end
end

RSpec.configure do |config|
  config.before :each do
    Mongoid.default_session.collections.select {|c| c.name !~ /system/ }.each(&:drop)
  end
end
