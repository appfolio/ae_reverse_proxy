# frozen_string_literal: true

require_relative "lib/ae_reverse_proxy"

Gem::Specification.new do |spec|
  spec.name                          = "ae_reverse_proxy"
  spec.version                       = AeReverseProxy::VERSION
  spec.platform                      = Gem::Platform::RUBY
  spec.authors                       = ["Appfolio"]
  spec.email                         = ["opensource@appfolio.com"]
  spec.summary                       = "Gem for reverse proxying requests."
  spec.description                   = spec.summary
  spec.license                       = "MIT"
  spec.required_ruby_version         = Gem::Requirement.new(">= 2.4.0")
  spec.files                         = Dir['**/*'].select { |f| f[%r{^(lib/|Gemfile$|Rakefile|README.md|.*gemspec)}] }
  spec.require_paths                 = ["lib"]
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.add_runtime_dependency('rack', '~> 2.2.3')
  spec.add_runtime_dependency('addressable', '>= 2.3.6')
end
