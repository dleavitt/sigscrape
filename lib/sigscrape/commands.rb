module Sigscrape
  module Commands
    def self.create_or_update_user(name, password)
      user = Models::User.find_or_initialize_by(name: name)
      user.password = password
      user.save!
      user
    end

    def self.log_in_user(u, service = nil)
      (service || Services::Sigalert.new).login(u.name, u.password)
    end

    def self.log_in_to_site(name, password, service = nil)
      user = Models::User.find_or_initialize_by(name: name, password: password)
      begin
        log_in_user(user, service)
        user.save!
        user
      rescue Services::Sigalert::InvalidCredentials => ex
        nil
      end
    end

    def self.update_user_journeys(user, service = nil)
      service = log_in_user(user, service)

      service.get_routes.map do |route_data|
        route = user.routes.find_or_initialize_by(sa_id: route_data[:id])
        route.name = route_data[:name]
        route.save!

        journey = route.journeys.create({
          retrived_at: Time.now,
          minutes: route_data[:minutes],
        })
      end
    end

    def self.group_journeys_by_time(route, interval=10.minutes)
      route.journeys.group_by do |journey|
        time_of_day = journey.created_at.round_off(interval)
        [ [ time_of_day.hour, time_of_day.min ], journey.created_at.wday ]
      end
    end
  end
end
