# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|

    policy.default_src :self, :https

    # Allow Vite's WebSocket connection in development for hot module reloading (HMR)
    policy.connect_src :self, :https, "ws://localhost:3036" if Rails.env.development?

    # Allow fonts from self and https
    policy.font_src    :self, :https, :data

    # Allow images from self, https, and data URLs
    policy.img_src     :self, :https, :data

    # Disallow all objects like Flash
    policy.object_src  :none

    # Allow scripts from self and https
    policy.script_src  :self, :https
    # Allow inline styles and scripts for testing (not production)
    # policy.script_src *policy.script_src, :blob if Rails.env.test?
    # Allow @vite/client to hot reload javascript changes in development
    policy.script_src *policy.script_src, :unsafe_eval, :unsafe_inline, "ws://#{ ViteRuby.config.host_with_port }" if Rails.env.development?

    # Allow connections from self and https
    policy.connect_src  :self, :https
    # Allow @vite/client to hot reload javascript changes in development
    policy.connect_src *policy.default_src, "ws://#{ ViteRuby.config.host_with_port }" if Rails.env.development?

    policy.style_src *policy.style_src, :blob if Rails.env.test?
    # You may need to enable these in production as well depending on your setup.

    # Allow styles from self and https
    policy.style_src   :self, :https
    # Allow @vite/client to hot reload style changes in development
    if Rails.env.development?
      policy.style_src(*policy.style_src, :unsafe_inline)
    end

    # Specify URI for violation reports
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w(script-src style-src)

  # Report violations without enforcing the policy.
  # config.content_security_policy_report_only = true
end
