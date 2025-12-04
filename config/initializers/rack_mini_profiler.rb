# frozen_string_literal: true

if Rack.const_defined?(:MiniProfiler) && Rails.env.development?
  Rack::MiniProfiler.config.authorization_mode = :allow_all
  Rack::MiniProfiler.config.disable_caching = false
  Rack::MiniProfiler.config.pre_authorize_cb = ->(_env) { true }
end
