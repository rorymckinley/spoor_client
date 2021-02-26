# frozen_string_literal: true

require_relative "lib/spoor_client/version"

Gem::Specification.new do |spec|
  spec.name          = "spoor_client"
  spec.version       = SpoorClient::VERSION
  spec.authors       = ["Rory McKinley"]
  spec.email         = ["rorymckinley@gmail.com"]

  spec.summary       = "A client for the Spoor service"
  spec.homepage      = "https://github.com/rorymckinley/spoor_client.git"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "email_address", "~> 0.1.20"
  spec.add_dependency "maxmind-geoip2", "~> 0.5.0"

  spec.add_development_dependency "dotenv", "~> 2.7.6"
  spec.add_development_dependency "pry", "~> 0.14.0"
  spec.add_development_dependency "rspec", "~> 3.10.0"
  spec.add_development_dependency "vcr", "~> 6.0.0"
  spec.add_development_dependency "webmock", "~> 3.11.2"

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"

  # For more information and examples about making a new gem, checkout our
  # guide at: https://bundler.io/guides/creating_gem.html
end
