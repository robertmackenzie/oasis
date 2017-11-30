require "rack/test"
require "json"
require "cgi/util"

RSpec.describe "/services" do
  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  def recursive_merge(hash_a, hash_b)
    hash_a.merge(hash_b) do |key, old_val, new_val|
      if (old_val.is_a? Hash and new_val.is_a? Hash)
        recursive_merge(old_val, new_val)
      else
        new_val
      end
    end
  end

  def service_definition(override={})
    File.open("./spec/fixtures/service.json") do |file|
      # remove \n and \t and \w formatting
      JSON.generate(recursive_merge(JSON.parse(file.read), override))
    end
  end

  describe "/services" do
    describe "POST" do
      context "no service exists" do
        before :each do
          post "/services", service_definition
        end

        it "should return a 201 status code" do
          expect(last_response.status).to eq 201
        end

        it "should return a service representation" do
          expect(last_response.body).to eq service_definition
        end
      end
    end
  end

  describe "/services/:name" do
    describe "GET" do
      before :each do
        post "/services", service_definition
      end

      it "should return a 200 status code" do
        get "/services/my-test-service"

        expect(last_response.status).to eq 200
      end

      it "should return a service representation" do
        get "/services/my-test-service"

        expect(last_response.body).to eq service_definition
      end
    end
  end

  describe "/services/:name/api" do
    it "should respond to a matching request with the specified handler" do
      post "/services", service_definition
      get "/services/my-test-service/api/my-test-service"

      expect(last_response.status).to eq 200
      expect(last_response.body).to eq '{ "content": "this is some content" }'
    end

    context "an echo-service has been created" do
      before :each do
        body_echo_service = service_definition({
          "route" => {
            "method" => "POST"
          },
          "handler" => {
            "status" => "418",
            "body" => "{{req.body}}",
            "headers" => {
              "Content-Type" => "{{req.headers.accept}}; charset={{req.headers.accept_charset}}"
            }
          }
        })

        post "/services", body_echo_service
      end

      it "should template the response by request params" do
        post "/services/my-test-service/api/my-test-service", "a body to echo",
          {
            "CONTENT_TYPE" => "text/vnd.oasis.v1+plain",
            "HTTP_ACCEPT" => "text/vnd.oasis.v1+plain",
            "HTTP_ACCEPT_CHARSET" => "utf-8"
          }

        expect(last_response.status).to eq 418
        expect(last_response.body).to eq "a body to echo"
        expect(last_response.headers["Content-Type"]).to eq "text/vnd.oasis.v1+plain; charset=utf-8"
      end
    end

  end

  describe "body escaping" do
    def response_body(text)
      "<h1>The body of your POST request</h1><p>#{text}</p>"
    end

    request_body = "<p>this HTML tag p tag should be escaped</p>"

    before :each do
      body_echo_service = service_definition({
        "route" => {
          "method" => "POST"
        },
        "handler" => {
          "status" => "200",
          "body" => response_body("{{req.body}}"),
          "headers" => {
            "Content-Type" => "{{req.headers.accept}}"
          }
        }
      })

      post "/services", body_echo_service
    end

    context "the response Content-Type is text/html" do
      it "should html escape tags in the body" do
        post "/services/my-test-service/api/my-test-service", request_body,
          {
            "CONTENT_TYPE" => "text/plain",
            "HTTP_ACCEPT" => "text/html"
          }

        expect(last_response.body).to eq response_body(CGI.escapeHTML(request_body))
      end
    end

    context "the response Content-Type is not text/html" do
      it "should not html escape tags in the body" do
        post "/services/my-test-service/api/my-test-service", request_body,
          {
            "CONTENT_TYPE" => "text/plain",
            "HTTP_ACCEPT" => "text/plain"
          }

          expect(last_response.body).to eq response_body(request_body)
      end
    end
  end
end
