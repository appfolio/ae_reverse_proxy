# frozen_string_literal: true

case RUBY_VERSION
when '3.1.3', '3.2.1', '3.3.0'
  appraise "ruby-#{RUBY_VERSION}_rack2" do
    source 'https://rubygems.org' do
      gem 'rack', '~> 2.2'
    end
  end

  appraise "ruby-#{RUBY_VERSION}_rack3" do
    source 'https://rubygems.org' do
      gem 'rack', '~> 3.0'
    end
  end
else
  raise "Unsupported Ruby version #{RUBY_VERSION}"
end
