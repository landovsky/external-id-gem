# frozen_string_literal: true

require_relative "lib/external_id/version"

Gem::Specification.new do |spec|
  spec.name = "external_id"
  spec.version = ExternalId::VERSION
  spec.authors = ["Tomáš Landovský"]
  spec.email = ["landovsky@gmail.com"]

  spec.summary = "Polymorphic external ID associations for Rails models"
  spec.description = "A Rails gem that provides a clean way to associate external IDs from third-party systems with your ActiveRecord models using polymorphic associations."
  spec.homepage = "https://github.com/yourusername/external-id"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.7.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 6.0"
  spec.add_dependency "activesupport", ">= 6.0"
  spec.add_dependency "railties", ">= 6.0"

  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-rails", "~> 6.0"
  spec.add_development_dependency "sqlite3", ">= 2.1"
  spec.add_development_dependency "factory_bot", "~> 6.0"
end
