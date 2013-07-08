module Sigscrape
  module Models
    class User
      include Mongoid::Document
      include Mongoid::Timestamps

      store_in collection: "users"

      field :name, type: String
      field :password, type: String

      embeds_many :routes

      index({name: 1}, unique: true)
      index({"routes.journeys.id" => 1}, unique: true)
      index({"routes.journeys.id" => 1, "journeys.retrieved_at" => 1})
    end

    class Route
      include Mongoid::Document
      include Mongoid::Timestamps

      store_in collection: "routes"

      field :name, type: String
      field :sa_id, type: Integer

      embedded_in :user
      embeds_many :journeys
    end

    class Journey
      include Mongoid::Document
      include Mongoid::Timestamps

      store_in collection: "journeys"

      field :retrieved_at, type: DateTime
      field :minutes, type: Float

      embedded_in :route
    end
  end
end