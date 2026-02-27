# frozen_string_literal: true

# Security Event Model - SOC2 Compliance
class SecurityEvent < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :resolved_by, class_name: 'User', optional: true

  validates :event_type, :severity, presence: true

  encrypts :details if Rails.application.credentials.secret_key_base.present?

  scope :unresolved, -> { where(resolved: false) }
  scope :critical, -> { where(severity: 'critical') }
  scope :recent, -> { order(created_at: :desc) }

  # Log security event
  def self.log_event(type:, severity: 'low', user: nil, details: nil, request: nil)
    create!(
      user: user,
      event_type: type,
      severity: severity,
      ip_address: request&.remote_ip,
      details: details&.to_json
    )
  end

  # Alert on critical events
  after_create :alert_if_critical

  private

  def alert_if_critical
    if severity == 'critical' && !resolved
      # Send alert (email, Slack, PagerDuty, etc.)
      SecurityMailer.critical_event(self).deliver_later
    end
  end
end

# Access Control Log Model
class AccessControlLog < ApplicationRecord
  belongs_to :user

  validates :permission, presence: true

  def self.log_access_attempt(user:, resource:, permission:, granted:, reason: nil)
    create!(
      user: user,
      resource_type: resource&.class&.name,
      resource_id: resource&.id,
      permission: permission,
      granted: granted,
      reason: reason
    )
  end
end
