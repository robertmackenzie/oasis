require "./lib/model/route"
require "./lib/model/request"

include Oasis::Model

RSpec.describe Route do
  describe "#=~" do
    {
      Route.new(method: "GET", path: "/my-test-service") =>
      Request.new(mock_rack_request),
      Route.new(method: "GET", path: "/my-test-service", headers: { "Content-Type" => "application/json" }) =>
      Request.new(mock_rack_request(headers: { "Content-Type" => "application/json" })),
      Route.new(method: "GET", path: "/my-test-service", params: { "name" => "Joe" }) =>
      Request.new(mock_rack_request(params: { "name" => "Joe" })),
      Route.new(method: "GET", path: "/my-test-service", body: "this is a riveting body") =>
      Request.new(mock_rack_request(body: "this is a riveting body")),
      Route.new(method: "GET", path: %r{^/my-test.+}, body: "this is a riveting body") =>
      Request.new(mock_rack_request(method: "GET", path: "/my-test-service-of-doom", body: "this is a riveting body")),
      Route.new(method: "GET", path: "/my-test-service", headers: { "Content-Type" => %r{application/[json|xml]} }) =>
      Request.new(mock_rack_request(headers: { "Content-Type" => "application/xml" })),
      Route.new(method: "GET", path: "/my-test-service", headers: { "Content-Type" => %r{^application/(:?json|xml)$}, "Accept-Encoding" => %r{\A(:?gzip|deflate)\Z} }) =>
      Request.new(mock_rack_request(headers: { "Content-Type" => "application/xml", "Accept-Encoding" => "gzip" })),
      Route.new(method: "GET", path: "/my-test-service", headers: { "Content-Type" => %r{^application/(:?json|xml)$}, "Accept-Encoding" => %r{\A(:?gzip|deflate)\Z} }, params: { "name" => %r{J.+} }, body: "this is a body") =>
      Request.new(mock_rack_request(headers: { "Content-Type" => "application/xml", "Accept-Encoding" => "gzip" }, params: { "name" => "Joe" }, body: "this is a body"))
    }.each do |route_a, route_b|
      it "#{route_a.to_json} =~ #{route_b.to_json} should return true" do
        result = route_a =~ route_b
        expect(result).to eq true
      end
    end

    {
      Route.new(method: "GET", path: "/my-test-service") =>
      Request.new(mock_rack_request(path: "/another-test-service")),
      Route.new(method: "GET", path: "/my-test-service") =>
      Request.new(mock_rack_request(method: "POST", path: "/my-test-service")),
      Route.new(method: "GET", path: "/my-test-service", headers: { "Content-Type" => "application/json" }) =>
      Request.new(mock_rack_request),
      Route.new(method: "GET", path: "/my-test-service", params: { "name" => "Joe" }) =>
      Request.new(mock_rack_request),
      Route.new(method: "GET", path: "/my-test-service", body: "this is a riveting body") =>
      Request.new(mock_rack_request(body: "this is a riveting body with bells on")),
      Route.new(method: "GET", path: %r{^/my-testing.+}, body: "this is a riveting body") =>
      Request.new(mock_rack_request(path: "/my-test-service-of-doom", body: "this is a riveting body")),
      Route.new(method: "GET", path: "/my-test-service", headers: { "Content-Type" => %r{application/(json|xml)} }) =>
      Request.new(mock_rack_request(headers: { "Content-Type" => "text/html" })),
      Route.new(method: "GET", path: "/my-test-service", headers: { "Content-Type" => %r{^application/(:?json|xml)$}, "Accept-Encoding" => %r{\A(:?gzip|deflate)\Z} }) =>
      Request.new(mock_rack_request(headers: { "Content-Type" => "application/xmli", "Accept-Encoding" => "gzip" })),
      Route.new(headers: { "Content-Type" => %r{^application/(:?json|xml)$}, "Accept-Encoding" => %r{\A(:?gzip|deflate)\Z} }, params: { "name" => %r{J.+} }, body: "this is a body") =>
      Request.new(mock_rack_request(headers: { "Content-Type" => "application/xml", "Accept-Encoding" => "gzip" }, params: { "name" => "Roe" }, body: "this is a body"))
    }.each do |route_a, route_b|
      it "#{route_a.to_json} =~ #{route_b.to_json} should return false" do
        result = route_a =~ route_b
        expect(result).to eq false
      end
    end

  end
end
