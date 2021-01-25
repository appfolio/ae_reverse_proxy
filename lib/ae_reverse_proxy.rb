# frozen_string_literal: true

module AeReverseProxy
  VERSION = '1.0.0'
  autoload :Client, 'ae_reverse_proxy/client'
  autoload :ControllerCallbackMethod, 'ae_reverse_proxy/controller_callback_method'
end
