require "rack/test"

RSpec.describe "Routes" do
  include Rack::Test::Methods

  def app
    OUTER_APP
  end

  describe "/ping" do
    describe "GET" do
      it "should return the text 'pong'" do
        get "/ping"
        expect(last_response.body).to eq "pong"
      end
    end
  end
end
