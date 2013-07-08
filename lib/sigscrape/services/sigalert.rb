require 'typhoeus/adapters/faraday'

module Sigscrape
  module Services
    class Sigalert
      BASE_URI        = "http://www.sigalert.com"
      AUTH_ENDPOINT   = "/Ajax/Login.asp"
      ROUTES_ENDPOINT = "/Ajax/GetSavedRoutes.asp"
      PATH_ENDPOINT   = "/Ajax/GetRoutePaths.asp?id={id}&path=1&count=3"

      attr_accessor :conn

      def initialize()
        @conn = Faraday.new url: BASE_URI, params: {tenant: 10} do |c|
          c.use FaradayMiddleware::ParseJson
          c.use FaradayMiddleware::Mashify
          c.use Faraday::Request::UrlEncoded
          c.use Faraday::CookieJar
          c.adapter :typhoeus
          # allows customization of the connection (for testing)
          yield c if block_given?
        end
      end

      def login(name, password)
        @conn.post AUTH_ENDPOINT, { name: name, password: password }
        self
      end

      def get_routes
        @conn.get(ROUTES_ENDPOINT).body.map do |r|
          # TODO: can a route have multiple paths?
          path = r["routes"][0]["paths"][0]
          { id: r["id"],
            name: path["name"],
            minutes: path["minutes"], }
        end
      end

      # unused for now
      def get_paths(route_ids)
        path_responses = []
        @conn.in_parallel do
          path_responses = route_ids.map do |id|
            @conn.get(PATH_ENDPOINT.gsub('{id}', id.to_s))
          end
        end

        path_responses.map.with_index do |response, i|
          # just get the first one for now
          path = response.body["paths"][0]
          { name: path["name"], minutes: path["minutes"], id: route_ids[i] }
        end
      end
    end
  end
end
