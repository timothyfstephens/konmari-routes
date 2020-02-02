module Konmari
  module Routes
    # The configuration object holding the necessary data for {Loader} to do its thing.
    class Configuration
      attr_writer :application
      # @return [Pathname] the folder containing the routing hierarchy to build
      attr_accessor :routes_path
      attr_writer :logger

      # @return [Logger] the logger to use for debugging purposes (optional, defaults to +Rails.logger+ if using Rails)
      def logger
        @logger || (Object.const_defined?(:Rails) ? Rails.logger : nil)
      end

      # @return [Application] the application to build these routes for (defaults to +Rails.application+ if using Rails)
      def application
        @application || (Object.const_defined?(:Rails) ? Rails.application : nil)
      end
    end
  end
end
