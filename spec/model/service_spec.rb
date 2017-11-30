require "./lib/model/service"
require "./lib/model/route"
require "./lib/model/handler"

include Oasis::Model

RSpec.describe NullService do
  describe ".process" do
    it "should return a 404 response" do
      request = Request.new({})
      status, headers, body = NullService.process(request)
      expect(status).to eq 404
      expect(headers).to eq "Content-Type" => "application/json"
      expect(body).to eq JSON.generate({ error: "service not found" })
    end
  end
end

RSpec.describe Service do
  describe ".from_hash" do
    it "should create a Service instance from a hash representation" do
      service_representation = {
        "route" => {
          "method" => "GET",
          "path" => "/my-test-service",
          "headers" => {},
          "params" => {},
          "body" => "a body"
        },
        "handler" => {
          "status" => 200,
          "headers" => {},
          "body" => "test service"
        }
      }
      service = Service.from_hash(service_representation)

      expect(service).to be_a Service
    end
  end

  describe ".new" do
    it "should create a Service instance from a Route and Handler instances" do
      route = Route.new(method: "GET", path: "/my-test-service", headers: {}, params: {}, body: "")
      handler = Handler.new(status: 200, headers: {}, body: "this is a body")
      service = Service.new("my-test-service", route, handler)

      expect(service).to be_a Service
    end
  end


  describe "#process" do
    context "a matching request is made" do
      it "should forward to the Route object provided" do
        route = Route.new(method: "GET", path: "/my-test-service", headers: {}, params: {}, body: "")
        class MockHandler
          @processed = false

          def self.process(route)
            @processed = true
          end

          def self.processed?
            @processed
          end
        end
        request = Request.new(mock_rack_request)

        Service.new("my-test-service", route, MockHandler).process(request)

        expect(MockHandler.processed?).to eq true
      end
    end

    context "a non-matching request is made" do
      it "should bypass the named service and return a 404 response" do
        SERVICE_NOT_FOUND_JSON_BODY = JSON.generate({ error: "service not found" })
        not_found_response = [404, {"Content-Type" => "application/json"}, SERVICE_NOT_FOUND_JSON_BODY]

        route = Route.new(method: "GET", path: "/my-test-service", headers: {}, params: {}, body: "")
        class MockHandler
          @processed = false

          def self.process(route)
            @processed = true
          end

          def self.processed?
            @processed
          end
        end
        request = Request.new(mock_rack_request(path: "/another-test-service"))

        response = Service.new("my-test-service", route, MockHandler).process(request)

        expect(MockHandler.processed?).to eq false
        expect(response).to eq not_found_response
      end
    end
  end

  describe "#to_json" do
    it "should return a json representation of a service" do
      route = Route.new(method: "GET", path: "/my-test-service", headers: {}, params: {}, body: "a body")
      handler = Handler.new(status: 200, headers: {}, body: "a body")
      service = Service.new("my-test-service", route, handler)

      expect(service.to_json).to eq '{"name":"my-test-service","route":{"method":"GET","path":"/my-test-service","headers":{},"params":{},"body":"a body"},"handler":{"status":200,"headers":{},"body":"a body"}}'
    end
  end
end
