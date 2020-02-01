require "konmari/routes/version"

module Konmari
  module Routes
    def config
      Loader.new(yield Configuration.new).build_routes if block_given?
    end
  end
end
