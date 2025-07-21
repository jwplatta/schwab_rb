# frozen_string_literal: true

require_relative "lib/schwab_rb/version"

Gem::Specification.new do |spec|
  spec.name = "schwab_rb"
  spec.version = SchwabRb::VERSION
  spec.authors = ["Joseph Platta"]
  spec.email = ["jwplatta@gmail.com"]

  spec.summary = "Ruby client for the Charles Schwab API"
  spec.description = "A comprehensive Ruby client for interacting with the Charles Schwab API. Provides access to account data, market quotes, options chains, order management, and more with both synchronous and asynchronous support."
  spec.homepage = "https://github.com/jwplatta/schwab_rb"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/jwplatta/schwab_rb"
  spec.metadata["changelog_uri"] = "https://github.com/jwplatta/schwab_rb/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "async", "~> 2.18"
  spec.add_dependency "async-http", "~> 0.82"
  spec.add_dependency "sinatra", "~> 4.1.1"
  spec.add_dependency "oauth2", "~> 2.0", ">= 2.0.9"
  spec.add_dependency "puma", "~> 6.5"
  spec.add_dependency "rackup", "~> 2.2"
  spec.add_dependency "openssl", "~> 3.1"
  spec.add_dependency "dotenv"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "async-rspec", "~> 1.17"
  spec.add_development_dependency "rubocop", "~> 1.21"
  spec.add_development_dependency "pry", "~> 0.14.2"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata["rubygems_mfa_required"] = "true"
end
