# frozen_string_literal: true

require_relative "lib/react_to_rails/version"

Gem::Specification.new do |spec|
  spec.name = "react_to_rails"
  spec.version = ReactToRails::VERSION
  spec.authors = ["Andy Waite"]
  spec.email = ["13400+andyw8@users.noreply.github.com"]

  spec.summary = "Converts React components to Rails using AI"
  spec.homepage = "https://github.com/andyw8/react_to_rails"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) || f.start_with?(*%w[bin/ test/ .git .github Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "openai", "~> 0.6"
  spec.add_dependency "zeitwerk", "~> 2.7"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
