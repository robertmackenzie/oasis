require "rubygems"
require "bundler"
require "./lib/app"

# If developing, require tools like pry, else setup gem paths and explicitly
# require as needed.
Bundler.setup(:default)
Bundler.require(:development) if ENV["RACK_ENV"] == "development"

run Oasis::Application.build
