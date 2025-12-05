# frozen_string_literal: true

# Explicitly configure CSP so the Vite dev server can talk to Rails in Docker.
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src(:self, :https)
    policy.font_src(:self, :https, :data)
    policy.img_src(:self, :https, :data, :blob)
    policy.object_src(:none)
    policy.script_src(:self, :https)
    policy.style_src(:self, :https)
    policy.connect_src(:self, :https)
    policy.base_uri(:self, :https)
    policy.frame_ancestors(:self, :https)

    if Rails.env.development? && defined?(ViteRuby)
      host_with_port = ViteRuby.config.host_with_port
      http_endpoint = "http://#{host_with_port}"
      ws_endpoint = "ws://#{host_with_port}"

      policy.script_src(*policy.script_src, :unsafe_eval, http_endpoint)
      policy.style_src(*policy.style_src, :unsafe_inline, http_endpoint)
      policy.connect_src(*policy.connect_src, http_endpoint, ws_endpoint)
    end
  end

  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  # In development, omit style-src from nonce directives so unsafe-inline works for Inertia/Vite HMR styles
  config.content_security_policy_nonce_directives = Rails.env.development? ? %w[script-src] : %w[script-src style-src]
end
