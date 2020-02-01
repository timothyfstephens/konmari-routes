module Konmari
  module Routes
    class RailsReloader
      def initialize(app)
        @app = app
      end

      def call(env)
        routes_reloader.execute_if_updated
        return *@app.call(env)
      end

      private
      def routes_reloader
        @routes_reloader ||= ActiveSupport::FileUpdateChecker.new([], rails_routes) do
          Rails.logger.info "Change detected, reloading routes..."
          Rails.application.reload_routes!
        end
      end

      def rails_routes
        {Rails.root.join("config/routes").to_s => ["routes", "rb"]}
      end
    end
  end
end
