# AeReverseProxy

A reverse proxy accepts a request from a client, forwards it to a server that can fulfill it, and returns the server's response to the client

This is forked from https://github.com/axsuul/rails-reverse-proxy. Thanks to https://github.com/axsuul and contributors.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ae_reverse_proxy'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install ae_reverse_proxy
```

Use it in a console with:

```bash
$ ./console
```

## Usage

```ruby
class ImageController < ActionController::Base
  include AeReverseProxy::ControllerCallbackMethod

  before_action do
    reverse_proxy('https://www.another_server.com')
  end
end
```

Reference implementation: https://github.com/appfolio/screenings_app/blob/master/app/controllers/concerns/ssuid_forwardable.rb

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
