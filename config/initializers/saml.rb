# frozen_string_literal: true

# SAML 2.0 configuration for Enterprise SSO
# Uses ruby-saml gem (OneLogin::RubySaml)
#
# Per-provider settings are built in SamlProvider#saml_settings.
# This initializer can be used for global defaults if needed.

Rails.application.config.after_initialize do
  # Optional: Configure ruby-saml logging
  # OneLogin::RubySaml::Logging.logger = Rails.logger
end
