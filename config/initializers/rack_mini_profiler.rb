# frozen_string_literal: true

# require "prepend_net_http_patch"
require "rack-mini-profiler"

if Rack.const_defined?(:MiniProfiler)
  Rack::MiniProfiler.config.authorization_mode = :allow_all
  Rack::MiniProfiler.config.disable_caching = false
end
