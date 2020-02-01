module Konmari
  module Routes
    class Configuration
      attr_accessor :application,
                    :routes_path,
                    :logger

      def logger
        @logger || (Object.const_defined?(:Rails) ? Rails.logger : nil)
      end

      def application
        @application || (Object.const_defined?(:Rails) ? Rails.application : nil)
      end
    end
  end
end
