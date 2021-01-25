# frozen_string_literal: true

require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'ae_reverse_proxy'
require 'rack/mock'

require 'minitest/autorun'
require 'mocha/minitest'
require 'webmock/minitest'
