# frozen_string_literal: true

require 'rack'
require 'addressable/uri'

module AeReverseProxy
  class Client
    attr_accessor :uri, :callbacks

    CALLBACK_METHODS = %i[
      on_response
      on_set_cookies
      on_connect
      on_success
      on_redirect
      on_missing
      on_error
      on_complete
    ].freeze

    # Define callback setters
    CALLBACK_METHODS.each do |method|
      define_method(method) do |&block|
        callbacks[method] = block
      end
    end

    def initialize(uri)
      self.uri = uri
      self.callbacks = CALLBACK_METHODS.to_h { |method| [method, proc {}] }

      yield(self) if block_given?
    end

    def forward_request(env, options = {})
      # Initialize requests
      source_request = Rack::Request.new(env)
      target_request = Net::HTTP.const_get(source_request.request_method.capitalize).new(source_request.fullpath)

      # Setup headers for forwarding.
      target_request_headers = extract_http_request_headers(source_request.env).merge({
        'ORIGIN' => uri.origin,
        'HOST' => uri.authority,
      })
      target_request.initialize_http_header(target_request_headers)

      # Setup basic auth.
      target_request.basic_auth(options[:username], options[:password]) if options[:username] && options[:password]

      # Setup body.
      if target_request.request_body_permitted? && source_request.body
        source_request.body.rewind
        target_request.body_stream = source_request.body
      end

      # Setup content encoding and type.
      target_request.content_length = source_request.content_length || 0
      target_request.content_type   = source_request.content_type if source_request.content_type

      # Don't encode response/support compression which was
      # causing content length not match the actual content
      # length of the response which ended up causing issues
      # within Varnish (503)
      target_request['Accept-Encoding'] = nil

      # Setup HTTP SSL options.
      http_options = {}
      http_options[:use_ssl] = (uri.scheme == 'https')

      # Make the request.
      target_response = nil
      Net::HTTP.start(uri.hostname, uri.port, http_options) do |http|
        callbacks[:on_connect].call(http)
        target_response = http.request(target_request)
      end

      # Initiate callbacks.
      status_code = target_response.code.to_i
      payload = [status_code, target_response]

      callbacks[:on_response].call(payload)

      if target_response.to_hash['set-cookie']
        set_cookies_hash = {}
        set_cookie_headers = target_response.to_hash['set-cookie']

        set_cookie_headers.each do |set_cookie_header|
          set_cookie_hash = parse_cookie(set_cookie_header)
          name = set_cookie_hash[:name]
          set_cookies_hash[name] = set_cookie_hash
        end

        callbacks[:on_set_cookies].call(payload | [set_cookies_hash])
      end

      case status_code
      when 200..299
        callbacks[:on_success].call(payload)
      when 300..399
        callbacks[:on_redirect].call(payload | [target_response['Location']]) if target_response['Location']
      when 400..499
        callbacks[:on_missing].call(payload)
      when 500..599
        callbacks[:on_error].call(payload)
      end

      callbacks[:on_complete].call(payload)

      payload
    end

    private

    COOKIE_PARAM_PATTERN = %r{\A([^(),/<>@;:\\"\[\]?={}\s]+)(?:=([^;]*))?\Z}.freeze
    COOKIE_SPLIT_PATTERN = /;\s*/.freeze

    def extract_http_request_headers(env)
      env
        .reject { |k, v| !(/^HTTP_[A-Z_]+$/ === k) || k == 'HTTP_VERSION' || v.nil? }
        .map { |k, v| [reconstruct_header_name(k), v] }
        .each_with_object(headers.new) do |k_v, hash|
          k, v = k_v
          hash[k] = v
        end
    end

    def headers
      Rack.release >= '3' ? Rack::Headers : Rack::Utils::HeaderHash
    end

    def reconstruct_header_name(name)
      name.sub(/^HTTP_/, '').gsub('_', '-')
    end

    def parse_cookie(cookie_str)
      params = cookie_str.split(COOKIE_SPLIT_PATTERN)
      info = params.shift.match(COOKIE_PARAM_PATTERN)
      return {} unless info

      cookie = {
        name: info[1],
        value: CGI.unescape(info[2]),
      }

      params.each do |param|
        result = param.match(COOKIE_PARAM_PATTERN)
        next unless result

        key = result[1].downcase.to_sym
        value = result[2]
        case key
        when :expires
          begin
            cookie[:expires] = Time.parse(value)
          rescue ArgumentError
          end
        when :httponly, :secure
          cookie[key] = true
        else
          cookie[key] = value
        end
      end

      cookie
    end
  end
end
