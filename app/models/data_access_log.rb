# frozen_string_literal: true

# Data Access Log for PHI tracking
class DataAccessLog < ApplicationRecord
  belongs_to :user
  belongs_to :account

  validates :data_type, :action, presence: true

  encrypts :justification if Rails.application.credentials.secret_key_base.present?

  scope :recent, -> { order(created_at: :desc) }
  scope :phi_access, -> { where(data_type: 'PHI') }

  # Log PHI access
  def self.log_phi_access(user:, account:, action:, justification: nil, request: nil)
    create!(
      user: user,
      account: account,
      data_type: 'PHI',
      action: action,
      justification: justification,
      ip_address: request&.remote_ip
    )
  end
end
