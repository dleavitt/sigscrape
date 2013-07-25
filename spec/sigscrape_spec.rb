require "spec_helper"

include Sigscrape

describe Sigscrape::Services::Sigalert do
  describe "#login" do
    it "doesn't explode" do
      client.login("asd", "123")
    end
  end

  describe "#get_routes" do
    it "returns an array" do
      client.login("asd", "123")
      client.get_routes.should be_a Array
    end

    it "has the correct values" do
      client.login("asd", "123")
      routes = client.get_routes
      routes.length.should be 2
      routes[0].should be_a Hash

      routes[0][:id].should be 807909
      routes[0][:name].should == "DTLA to Work"
      routes[0][:minutes].should == 23.168793337336165

      routes[1][:id].should be 807908
      routes[1][:name].should == "Work to DTLA"
      routes[1][:minutes].should == 25.677412119872656
    end
  end
end

describe Sigscrape::Commands do
  describe '.log_in_to_site' do
    context "with valid credentials" do
      context "where user exists" do
        before do
          @user = Models::User.create(name: "asd", password: "123")
          @user.save!
        end

        it "returns the existing user" do
          Commands.log_in_to_site("asd", "123", client).id.should eq @user.id
        end
      end

      context "where user does not exist" do
        it "creates a new user" do
          expect {
            Commands.log_in_to_site("asd", "123", client)
          }.to change{Models::User.count}.by(1)
        end
      end
    end
  end

  describe ".update_user_journeys" do
    let! :user do
      Sigscrape::Models::User.create(name: "asd", password: "123")
    end

    it "creates routes if they don't exist yet" do
      expect {
        Sigscrape::Commands.update_user_journeys(user, client)
      }.to change{user.reload.routes.count}.by(2)
    end

    it "creates the routes correctly" do
      Sigscrape::Commands.update_user_journeys(user, client)
      user.reload.routes[0].sa_id.should be 807909
      user.reload.routes[0].name.should == "DTLA to Work"
      user.reload.routes[1].sa_id.should be 807908
      user.reload.routes[1].name.should == "Work to DTLA"
    end

    it "doesn't recreate existing routes" do
      Sigscrape::Commands.update_user_journeys(user, client)
      expect {
        Sigscrape::Commands.update_user_journeys(user, client)
      }.not_to change{user.reload.routes.count}
    end

    it "creates journeys for new routes" do
      user.routes.count.should be 0
      Sigscrape::Commands.update_user_journeys(user, client)
      user.reload.routes[0].journeys.length.should be 1
    end

    it "adds journeys to existing routes" do
      Sigscrape::Commands.update_user_journeys(user, client)

      expect {
        Sigscrape::Commands.update_user_journeys(user, client)
        Sigscrape::Commands.update_user_journeys(user, client)
      }.to change{user.reload.routes[0].journeys.count}.by(2)
    end

    it "sets the minutes for journeys" do
      Sigscrape::Commands.update_user_journeys(user, client)
      user.reload.routes[0].journeys[0].minutes.should == 23.168793337336165
    end

    it "sets the retrieved at for journeys" do
      Sigscrape::Commands.update_user_journeys(user, client)
      retrieved_at = user.reload.routes[0].journeys[0].retrieved_at.to_i
      retrieved_at.should be_within(10).of(Time.now.to_i)
    end

    it "fails for a nonexistent user"
  end

  describe ".group_journeys_by_day_and_time" do
    before do
      Models::User.create(yaml_fixture('users_with_journeys'))
      @route = Models::User.find_by(name: 'user1').routes.first
    end

    it "includes only the correct journeys" do
      groups = Commands.group_journeys_by_day_and_time(@route)
      groups[[[22, 0], 3]].map(&:label).uniq.should eq ["yep"]
    end
  end

  describe ".group_journeys_by_time" do
    before do
      Models::User.create(yaml_fixture('users_with_journeys'))
      @route = Models::User.find_by(name: 'user1').routes.first
    end

    it "includes only the correct journeys" do
      groups = Commands.group_journeys_by_time(@route)
      groups[[22, 0]].map(&:label).uniq.should eq ["yep", "wrong_day"]
    end
  end
end

describe Sigscrape::App do
  # TODO: mock call
  include Rack::Test::Methods

  def app
    Sigscrape::App.new
  end

  describe "GET /" do
    before do
      get '/'
    end

    it "returns successfully" do
      last_response.status.should be 200
    end

    it "renders the 'login' template" do
      last_response.body.should match "find the best commute time"
    end

    it "does not show an error message" do
      last_response.body.should_not match "alert-error"
    end
  end

  describe "POST /login" do
    context "with empty params" do
      # TODO: sigalert response is stubbed with ANY credentials, so can't
      # test failure right now
      before do
        env "rack.session", { 'csrf.token' => 'token' }
        post "/login", { name: "nope", password: "nopass", _csrf: 'token' }
      end

      pending "re-renders the login page" do
        last_response.body.should match "find the best commute time"
      end

      pending "shows an error" do
        last_response.body.should match "alert-error"
      end
    end

    context "with valid params" do
      before do
        env "rack.session", { 'csrf.token' => 'token' }
        post "/login", { name: "asd", password: "123", _csrf: 'token' }
      end

      it "redirects to the logged in page" do
        last_response.status.should eq 302
      end
    end
  end
end
