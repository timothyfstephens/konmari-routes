module Konmari
  module Routes
    class Configuration
      attr_accessor :application,
                    :routes_path,
                    :logger

      def logger
        @logger || (const_defined?(Rails) ? Rails.logger : nil)
      end

      def application
        @application || (const_defined?(Rails) ? Rails.application : nil)
      end
    end
  end
end
