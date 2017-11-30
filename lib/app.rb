require "json"
require "rack/contrib/simple_endpoint"
require "./lib/model/service"
require "./lib/model/route"
require "./lib/model/request"
require "./lib/model/service_store"

module Oasis
  class Application
    include Model
    include Rack

    NOT_FOUND_JSON_BODY = JSON.generate({ error: "route not found" })

    def self.build
      Builder.app do
        use SimpleEndpoint, "/ping" => [:get, :post] do |req, res|
          "pong"
        end

        use SimpleEndpoint, %r{^/services/?$} => :post do |req, res|
          service = Service.from_hash(JSON.parse(req.body.read))
          ServiceStore.add(service)

          res.status = 201
          service.to_json
        end

        use SimpleEndpoint, %r{^/services/(?<name>.+)/api(?<path>/.+)?$} do |req, res, match|
          service = ServiceStore.get(match[:name])
          # avoid modifying req directly, confusing Rack::Test::Methods and
          # others
          req_dup = req.dup
          req_dup.path_info = match[:path]
          request = Oasis::Model::Request.new(req_dup)

          service.process(request) do |status, headers, body|
            res.status = status
            headers.each do |k, v|
              res.set_header(k, v)
            end
            body
          end
        end

        use SimpleEndpoint, %r{^/services/(?<name>.+)$} => :get do |req, res, match|
          service_result = ServiceStore.get(match[:name])

          if service_result.is_a? NullService
            :pass
          else
            service_result.to_json
          end
        end

        run lambda { |env|
          [404, {"Content-Type" => "application/json"}, [NOT_FOUND_JSON_BODY]]
        }
      end
    end
  end
end
