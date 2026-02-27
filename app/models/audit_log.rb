# frozen_string_literal: true

# HIPAA Audit Log Model
class AuditLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :account, optional: true

  validates :action, :occurred_at, presence: true

  encrypts :changes if Rails.application.credentials.secret_key_base.present?
  encrypts :phi_accessed if Rails.application.credentials.secret_key_base.present?

  # HIPAA requires audit logs be retained for 6 years
  scope :retention_period, -> { where('created_at > ?', 6.years.ago) }
  scope :recent, -> { order(occurred_at: :desc) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :for_account, ->(account_id) { where(account_id: account_id) }

  # Log an action
  def self.log_action(user:, account: nil, action:, resource: nil, changes: nil, phi: nil, request: nil)
    create!(
      user: user,
      account: account || user&.accounts&.first,
      action: action,
      resource_type: resource&.class&.name,
      resource_id: resource&.id,
      changes: changes&.to_json,
      phi_accessed: phi,
      ip_address: request&.remote_ip,
      user_agent: request&.user_agent,
      session_id: request&.session&.id&.to_s,
      occurred_at: Time.current
    )
  end

  # Generate HIPAA compliance report
  def self.compliance_report(account_id, start_date: 30.days.ago, end_date: Time.current)
    logs = where(account_id: account_id).where(occurred_at: start_date..end_date)
    
    {
      total_accesses: logs.count,
      unique_users: logs.distinct.count(:user_id),
      phi_accesses: logs.where.not(phi_accessed: nil).count,
      actions_breakdown: logs.group(:action).count,
      most_active_users: logs.group(:user_id).count.sort_by { |_, v| -v }.first(10),
      suspicious_activities: detect_suspicious_activities(logs)
    }
  end

  def self.detect_suspicious_activities(logs)
    suspicious = []
    
    # Detect unusual access patterns
    user_counts = logs.group(:user_id).count
    user_counts.each do |user_id, count|
      suspicious << { user_id: user_id, reason: "Excessive access", count: count } if count > 1000
    end
    
    # Detect after-hours access
    after_hours = logs.where('EXTRACT(HOUR FROM occurred_at) NOT BETWEEN 6 AND 18')
    if after_hours.any?
      suspicious << { reason: "After-hours access", count: after_hours.count }
    end
    
    suspicious
  end
end
