# frozen_string_literal: true

require_relative 'lib/ae_reverse_proxy/version'

Gem::Specification.new do |spec|
  spec.name                  = 'ae_reverse_proxy'
  spec.version               = AeReverseProxy::VERSION
  spec.platform              = Gem::Platform::RUBY
  spec.author                = 'AppFolio'
  spec.email                 = 'opensource@appfolio.com'
  spec.description           = 'Provides an implementation of a Rack-compliant reverse proxy, allowing Rack-based applications to forward incoming requests to upstream servers.'
  spec.summary               = 'Gem for reverse proxying requests.'
  spec.homepage              = 'https://github.com/appfolio/ae_reverse_proxy'
  spec.license               = 'MIT'
  spec.files                 = Dir['**/*'].select { |f| f[%r{^(lib/|LICENSE.txt|ae_reverse_proxy\.gemspec)}] }
  spec.require_paths         = ['lib']

  spec.required_ruby_version = Gem::Requirement.new('< 4.1')
  spec.metadata['allowed_push_host'] = 'https://rubygems.org'

  spec.add_dependency('addressable', ['>= 2.3.6', '< 3'])
  spec.add_dependency('rack', ['>= 2.2.3', '< 4'])
end
