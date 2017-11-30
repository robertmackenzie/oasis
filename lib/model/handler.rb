require "json"
require "./lib/model/view"
require "./lib/model/request_view"
require "active_support/core_ext/hash/indifferent_access"

module Oasis
  module Model
    class Handler
      attr_reader :status, :headers, :body

      def initialize(handler_definition)
        @status, @headers, @body =
          handler_definition.with_indifferent_access.values_at("status", "headers", "body")
      end

      def process(request, &block)
        data = { req: RequestView.new(request) }

        response_headers = headers.map do |k, v|
          [k, View.render(v, data)]
        end.to_h

        response_body = if (response_headers["Content-Type"] == "text/html")
          HTMLEscapedView.render(body, data)
        else
          View.render(body, data)
        end

        block.call([status, response_headers, response_body])
      end

      def to_json opts={}
        JSON.generate({
          status: status,
          headers: headers,
          body: body
        }, opts)
      end
    end
  end
end
