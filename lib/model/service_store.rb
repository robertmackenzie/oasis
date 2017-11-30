module Oasis
  module Model
    class ServiceStore
      @services = Hash.new(NullService)

      def self.add(service)
        @services[service.name] = service
      end

      def self.get(name)
        @services[name]
      end
    end
  end
end
