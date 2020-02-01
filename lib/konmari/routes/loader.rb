module Konmari
  module Routes
    class Loader
      # Given a routes directory, recursively load all routes, following this:
      # 1. Load the files in each directory that match PRIORITY_FILES in order listed
      # 2. Load each directory, opening a namespace matching the directory name, and start back at step 1
      # 3. Load all other files in alphabetical order
      #
      # Be aware that any routes will be respected in the order they are loaded
      # Routes files must name `.routes` or `.rb`

      EXPECTED_FILENAME_REGEX = /:(?<fname>.*?)\W/ unless const_defined?(:EXPECTED_FILENAME_REGEX)
      unless const_defined?(:PRIORITY_FILES)
        PRIORITY_FILES = [
          :priority,
          :redirects,
          :index
        ].freeze
      end

      def initialize(config)
        @app           = config.application
        @routes_folder = config.routes_path
        @logger        = config.logger
      end

      def build_routes
        do_router = -> (router) { load_routes(router) }

        # Something in the scoping in `.draw`
        # doesn't allow us to call load routes directly
        @app.routes.draw { do_router.call(self) }
      end

      private

      def load_routes(router)
        @router = router

        return unless @routes_folder&.exist?

        sorted_children(@routes_folder).each do |path|
          debug "Processing #{path}"
          handle_path(path)
        end
      end

      def handle_path(base_path)
        if base_path.directory?
          # if its a directory, use the directory name as the namespace

          ns = base_path.basename.to_s.to_sym
          debug "Adding namespace :#{ns}"
          @router.namespace ns do
            sorted_children(base_path).each do |path|
              handle_path path
            end
          end
        elsif base_path.file?
          process_file base_path
        end
      end

      def process_file(path)
        routes = File.read path

        # If its the index file, anything goes
        # Otherwise, get first line that is not a comment
        # or blank, and validate that this file is appropriately named
        unless priority_regex.match(path.basename.to_s)
          first_code_line = routes.split("\n").detect { |l| !l.empty? && !/^\s*#/.match(l) }

          expected_filename = EXPECTED_FILENAME_REGEX.match(first_code_line)

          if !expected_filename || !(path.basename.to_s =~ /^#{expected_filename[:fname]}\.routes$/)
            raise FilenameError, "Expected filename to match :#{expected_filename[:fname]} for #{path}"
          end
        end

        debug "Loaded routes from #{path}"

        @router.instance_eval routes
      end

      def sorted_children(folder_path)
        folder_path.children.sort_by do |path|
          if priority_regex =~ path.basename.to_s
            file_index = PRIORITY_FILES.index { |file_name| path.basename.to_s.start_with?(file_name.to_s) }
            "a_#{file_index}_#{path.basename}"
          elsif path.directory?
            "dir_#{path.basename}"
          else
            "file_#{path.basename}"
          end
        end
      end

      def priority_regex
        @priority_regex ||= /^(#{PRIORITY_FILES.join("|")})\.routes$/
      end

      def debug(message)
        return unless @logger.respond_to?(:debug)
        @logger.debug message
      end
    end

    class FilenameError < StandardError; end
  end
end
