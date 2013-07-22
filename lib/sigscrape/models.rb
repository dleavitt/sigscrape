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

      def journey_by_day_and_time

      end
    end

    class Journey
      include Mongoid::Document
      include Mongoid::Timestamps

      store_in collection: "journeys"

      field :retrieved_at, type: DateTime
      field :minutes, type: Float
      field :label, type: String  # optional
      
      embedded_in :route

      def local_time
        created_at.in_time_zone("Pacific Time (US & Canada)")
      end
    end
  end
end
