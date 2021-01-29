# frozen_string_literal: true

require 'test_helper'
require 'addressable/uri'

module AeReverseProxy
  class ClientTest < Minitest::Test
    # Got to the following resources for info on creating mock requests
    # https://github.com/rack/rack/blob/master/test/spec_request.rb
    # https://www.rubydoc.info/gems/rack/Rack/MockRequest
    # https://www.rubydoc.info/gems/rack/Rack/Request

    def test_initialize
      uri_str = 'https://www.appfoleo.com:8080'
      proxy_uri = Addressable::URI.parse(uri_str)

      client = Client.new(proxy_uri) do |config|
        Client::CALLBACK_METHODS.each do |method|
          config.send(method) do
            "#{method}_called"
          end
        end
      end

      assert_equal proxy_uri, client.uri
      Client::CALLBACK_METHODS.each do |method|
        assert_equal "#{method}_called", client.callbacks[method].call
      end
    end

    def test_forward_request__simple_get_request
      uri_str = 'https://www.appfoleo.com:8080'
      proxy_uri = Addressable::URI.parse(uri_str)

      client = Client.new(proxy_uri) do |config|
        config.on_success do |status_code, target_response|
          assert_equal 200, status_code
          assert_equal 'Everything is A-ok', target_response.body
        end
      end

      stub_request(:get, 'https://www.appfoleo.com:8080/posts')
        .with(
          headers: {
            'Content-Length' => '0',
            'Host' => 'www.appfoleo.com:8080',
            'Origin' => 'https://www.appfoleo.com:8080',
            'User-Agent' => 'Rails Testing',
          },
        ).to_return(status: 200, body: 'Everything is A-ok', headers: {})

      client.forward_request(test_env)
    end

    def test_forward_request__get_request_with_url_params
      uri_str = 'https://www.appfoleo.com:8080'
      proxy_uri = Addressable::URI.parse(uri_str)

      client = Client.new(proxy_uri) do |config|
        config.on_success do |status_code, target_response|
          assert_equal 200, status_code
          assert_equal 'Everything is A-ok', target_response.body
        end
      end

      stub_request(:get, 'https://www.appfoleo.com:8080/posts?sort=desc')
        .with(
          headers: {
            'Content-Length' => '0',
            'Host' => 'www.appfoleo.com:8080',
            'Origin' => 'https://www.appfoleo.com:8080',
            'User-Agent' => 'Rails Testing',
          },
        ).to_return(status: 200, body: 'Everything is A-ok', headers: {})

      client.forward_request(test_env_with_url_params)
    end

    private

    def test_env(env_opts = {})
      Rack::MockRequest.env_for('/posts', {
        'HTTP_HOST' => 'test.host'.b,
        'REMOTE_ADDR' => '0.0.0.0'.b,
        'HTTP_USER_AGENT' => 'Rails Testing'.b,
      }.merge(env_opts))
    end

    def test_env_with_url_params(env_opts = {})
      Rack::MockRequest.env_for('/posts?sort=desc', {
        'HTTP_HOST' => 'test.host'.b,
        'REMOTE_ADDR' => '0.0.0.0'.b,
        'HTTP_USER_AGENT' => 'Rails Testing'.b,
      }.merge(env_opts))
    end
  end
end
