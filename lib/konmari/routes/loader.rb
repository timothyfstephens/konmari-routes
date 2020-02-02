module Konmari
  module Routes
    # Given a routes directory, recursively load all routes.
    #
    # Recursively loads all routes in a directory following this algorithm:
    # 1. Load the files in each directory that match PRIORITY_FILES in order listed
    # 2. Load each directory, opening a *new namespace* matching the directory name, and start back at step 1
    # 3. Load all other files in alphabetical order
    #
    # Be aware that any routes will be respected in the order they are loaded
    # Routes files must use extension +.routes+
    #
    # Example file structure:
    #     |- routes/
    #     |  |- index.routes
    #     |  |- comments.routes
    #     |  |- users/
    #     |     |- index.routes
    #     |     |- friends.routes
    #
    # Analogous routes definitions
    #
    #     application.routes.draw do
    #       # all index routes
    #       # all comments routes (likely a resource, *must* have first code line of `resource/namespace :comments`)
    #       namespace :users do
    #         # all index routes from `index.routes` file in `users/`
    #         # all friends routes from `friends.routes` in `users/`
    #       end
    #     end
    #
    # The +friends.routes+ file could then be as simple as:
    #
    #    # routes/users/friends.routes
    #    # NOTE: the resource matches the filename
    #    resources :friends, only: [:index, :create, :delete], path: :my_friends # or any other options passed to resource(s)
    #
    # Point being, declaring the namespace is unnecessary.  This gives us the _huge_ advantage of being able to have our routes
    # files _exactly_ match the file heirarchy of our controllers.  We also have the flexibility, through the prioritized files,
    # to add any other routes we might need without being restrained by the filename constraint.
    #
    class Loader

      EXPECTED_FILENAME_REGEX = /:(?<fname>.*?)\W/ unless Object.const_defined?(:EXPECTED_FILENAME_REGEX)
      unless Object.const_defined?(:PRIORITY_FILES)
        # The list of filenames which are exempt from the resource name matching rule, and are always loaded first
        # in any directory they are seen in.
        PRIORITY_FILES = [
          :priority,
          :redirects,
          :index
        ].freeze
      end
      private_constant :EXPECTED_FILENAME_REGEX

      def initialize(config)
        @app           = config.application
        @routes_folder = config.routes_path
        @logger        = config.logger
        build_routes
      end

      private

      def build_routes
        do_router = -> (router) { load_routes(router) }

        # Something in the scoping in `.draw`
        # doesn't allow us to call load routes directly
        @app.routes.draw { do_router.call(self) }
      end

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

    # Raised when a filename does not have the correct extension, or the first detected line of code does not match the filename
    #
    # Eg:
    #
    #    # routes/thing/hello.route
    #    resource :world
    #
    # would raise this error for two reasons:
    # 1. The extension should be +.routes+
    # 2. The filename should be +world.routes+ or the resource should be +:hello+
    class FilenameError < StandardError; end
  end
end
