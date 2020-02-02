module Konmari
  module Routes
    # When using Rails, any changes to +config/routes.rb+ are detected by the server when developing and automatically reloaded.
    #
    # In order to mimic this behavior, add {Konmari::Routes::RailsReloader} as middleware in your +development.rb+ file:
    #
    #    Rails.application.configure do
    #      config.middleware.use Konmari::Routes::RailsReloader
    #
    #      ...
    #    end
    #
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
