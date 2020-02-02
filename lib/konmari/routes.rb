require "konmari/routes/version"
require "konmari/routes/loader"
require "konmari/routes/configuration"

module Konmari
  module Routes
    # (see Konmari::Routes::Loader)
    #
    # In your +config/routes.rb+ file, use this method to configure and then load all routes for the specified application from the provided
    # folder path.
    #
    # @yield [config] The {Konmari::Routes::Configuration} object used to configure the application route drawer.
    def self.config
      Loader.new(Configuration.new.tap { |config| yield config}) if block_given?
    end
  end
end
