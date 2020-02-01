require "konmari/routes/version"
require "konmari/routes/loader"
require "konmari/routes/configuration"

module Konmari
  module Routes
    def self.config
      Loader.new(Configuration.new.tap { |config| yield config}).build_routes if block_given?
    end
  end
end
