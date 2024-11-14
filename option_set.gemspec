# frozen_string_literal: true

require_relative "lib/option_set/version"

Gem::Specification.new do |spec|
  spec.name = "option_set"
  spec.version = OptionSet::VERSION
  spec.authors = ["Dan Loman"]
  spec.email = ["daniel.h.loman@gmail.com"]

  spec.summary = "OptionSets for ActiveRecord"
  spec.description = "OptionSets allow you to define a set of options and store them within a single integer column in your database. This can be useful for defining roles, permissions, or any other set of options that can be represented as a set of flags. This is inspired by Swift's OptionSet type. https://developer.apple.com/documentation/swift/optionset"
  spec.homepage = "https://github.com/namolnad/option_set"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/namolnad/option_set"
  spec.metadata["changelog_uri"] = "https://github.com/namolnad/option_set/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 6.1"
end
