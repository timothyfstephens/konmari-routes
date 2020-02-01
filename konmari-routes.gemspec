
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "konmari/routes/version"

Gem::Specification.new do |spec|
  spec.name          = "konmari-routes"
  spec.version       = Konmari::Routes::VERSION
  spec.authors       = ["Timothy Stephens"]
  spec.email         = ["timothy.f.stephens@gmail.com"]

  spec.summary       = %q{Only keep the routes that make you happy}
  spec.description   = %q{
    Inspired by thousand-line routes files, this gem aims to make those more manageable by enabling
    a routing structure that mirrors the file structure of a standard application.

    This is largely inspired by two articles:
      https://blog.lelonek.me/keep-your-rails-routes-clean-and-organized-83e78f2c11f2
      https://blog.arkency.com/2015/02/how-to-split-routes-dot-rb-into-smaller-parts/
  }
  spec.homepage      = "https://github.com/timothyfstephens/konmari-routes"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/timothyfstephens/konmari-routes"
    spec.metadata["changelog_uri"] = "https://github.com/timothyfstephens/konmari-routes/blob/master/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
