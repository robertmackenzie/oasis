require "forwardable"
require "./lib/model/route"
require "./lib/model/handler"
require "active_support/core_ext/hash/indifferent_access"

module Oasis
  module Model
    class NullService
      SERVICE_NOT_FOUND_JSON_BODY = JSON.generate({ error: "service not found" })

      @name = "null-service"
      @route = nil
      @handler = nil

      def self.process(route)
        response = [404, {"Content-Type" => "application/json"}, SERVICE_NOT_FOUND_JSON_BODY]

        if block_given?
          yield response
        else
          response
        end
      end

      def to_json opts={}
        JSON.generate({
          name: @name,
          route: @route,
          handler: @handler
        }, opts)
      end
    end

    class Service
      attr_reader :route, :name

      def self.from_hash(service_definition)
        route = Route.new(service_definition.with_indifferent_access["route"])
        handler = Handler.new(service_definition.with_indifferent_access["handler"])
        self.new(service_definition.with_indifferent_access["name"], route, handler)
      end

      def initialize(name, route, handler)
        @name = name
        @route = route
        @handler = handler
      end

      def process(request, &block)
        if(@route =~ request)
          @handler.process(request, &block)
        else
          NullService.process(request, &block)
        end
      end

      def to_json opts={}
        JSON.generate({
          name: @name,
          route: @route,
          handler: @handler
        }, opts)
      end
    end
  end
end
