require "json"

module Oasis
  module Model
    class BasicRequest
      def to_json opts={}
        JSON.generate({
          method: method,
          path: path,
          headers: headers,
          params: params,
          body: body
        }, opts)
      end
    end
  end
end
