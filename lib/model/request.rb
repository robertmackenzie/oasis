require "./lib/model/basic_request"

module Oasis
  module Model
    class Request < BasicRequest
      extend Forwardable

      def_delegators :@rack_request, :path, :params

      def initialize(rack_request)
        @rack_request = rack_request
      end

      def body
        @rack_request.body.rewind
        @rack_request.body.read
      end

      def method
        @rack_request.request_method
      end

      def headers
        # these helped understand what Rack is doing with headers:
        # http://www.rubydoc.info/github/rack/rack/master/file/SPEC
        # https://tools.ietf.org/html/rfc3875#section-4.1.18
        @rack_request.env.reduce({}) { |memo, kv|
          k, v = kv
          new_k, new_v = if (match = k.match(/^HTTP_(?<header>.+)$/) )
            [normalize_rack_header_key(match[:header]), v]
          elsif (k == "CONTENT_TYPE" or k == "CONTENT_LENGTH")
            [normalize_rack_header_key(k), v]
          end

          memo[new_k] = new_v unless new_k.nil?

          memo
        }
      end

      private

      def normalize_rack_header_key(string)
        string.downcase.gsub(/^(.)/) {
          $1.upcase
        }.gsub(/_(.)/) {
          "-#{$1.upcase}"
        }
      end

    end
  end
end
