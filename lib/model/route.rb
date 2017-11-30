require "./lib/model/basic_request"
require "active_support/core_ext/hash/indifferent_access"

module Oasis
  module Model
    class Route < BasicRequest
      attr_reader :method, :path, :headers, :params, :body

      def initialize(route_definition)
        # nil taken to mean "not a request constraint"
        @method, @path, @headers, @params, @body =
          route_definition.with_indifferent_access.values_at("method", "path", "headers", "params", "body")
      end

      # cases handled:
      # a AND b are String
      # a is a Regex, b is a String
      # a AND b are Hash
      # a is Nil, taken to mean NA
      def self.match?(a, b)
        case a
        when NIL
          true
        when String
          a == b
        when Regexp
          b =~ a or false
        when Hash
          a.all? { |k, v|
            bv = b[k]
            Route.match?(v, bv)
          }
        else false
        end
      end

      def =~(request)
        Route.match?(method, request.method) and
        Route.match?(path, request.path) and
        Route.match?(headers, request.headers) and
        Route.match?(params, request.params) and
        Route.match?(body, request.body)
      end
    end
  end
end
