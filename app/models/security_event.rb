# frozen_string_literal: true

class SecurityEvent < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :resolved_by, class_name: "User", optional: true

  validates :event_type, :severity, presence: true

  encrypts :details

  scope :unresolved, -> { where(resolved: false) }
  scope :critical, -> { where(severity: "critical") }
  scope :recent, -> { order(created_at: :desc) }

  def self.log_event(type:, severity: "low", user: nil, details: nil, request: nil)
    create!(
      user: user,
      event_type: type,
      severity: severity,
      ip_address: request&.remote_ip,
      details: details&.to_json
    )
  end

  after_create :alert_if_critical

  private

  def alert_if_critical
    return unless severity == "critical" && !resolved
    Rails.logger.warn "[SECURITY ALERT] Critical event: #{event_type} | User: #{user_id} | IP: #{ip_address}"
  end
end

class AccessControlLog < ApplicationRecord
  belongs_to :user

  validates :permission, presence: true

  def self.log_access_attempt(user:, resource:, permission:, granted:, reason: nil)
    create!(
      user: user,
      resource_type: resource.is_a?(String) ? resource : resource&.class&.name,
      resource_id: resource.is_a?(String) ? nil : resource&.id,
      permission: permission,
      granted: granted,
      reason: reason
    )
  end
end
