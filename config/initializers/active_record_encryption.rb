# frozen_string_literal: true

# Configure Active Record Encryption for sensitive data
# See: https://edgeguides.rubyonrails.org/active_record_encryption.html

Rails.application.config.active_record.encryption.primary_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY") {
  # Generate with: bin/rails db:encryption:init
  Rails.application.credentials.dig(:active_record_encryption, :primary_key) ||
  Rails.application.secret_key_base # Fallback for development
}

Rails.application.config.active_record.encryption.deterministic_key = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY") {
  Rails.application.credentials.dig(:active_record_encryption, :deterministic_key) ||
  Rails.application.secret_key_base
}

Rails.application.config.active_record.encryption.key_derivation_salt = ENV.fetch("ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT") {
  Rails.application.credentials.dig(:active_record_encryption, :key_derivation_salt) ||
  Rails.application.secret_key_base
}

# Store unencrypted data in development logs (for debugging)
Rails.application.config.active_record.encryption.support_unencrypted_data = Rails.env.development?

# Raise error when trying to decrypt invalid data (strict mode)
Rails.application.config.active_record.encryption.validate_column_size = false
