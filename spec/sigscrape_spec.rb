require "spec_helper"

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
  describe ".store_user_routes" do
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

    it "sets the right value for journeys" do
      Sigscrape::Commands.update_user_journeys(user, client)
      user.reload.routes[0].journeys[0].minutes.should == 23.168793337336165
    end

    it "fails for a nonexistent user"
  end
end
