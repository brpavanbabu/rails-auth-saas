# frozen_string_literal: true

class AuditLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :account, optional: true

  validates :action, :occurred_at, presence: true

  encrypts :changes
  encrypts :phi_accessed

  scope :retention_period, -> { where("created_at > ?", 6.years.ago) }
  scope :recent, -> { order(occurred_at: :desc) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :for_account, ->(account_id) { where(account_id: account_id) }

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

  def self.compliance_report(account_id, start_date: 30.days.ago, end_date: Time.current)
    logs = where(account_id: account_id).where(occurred_at: start_date..end_date)

    {
      total_accesses: logs.count,
      unique_users: logs.distinct.count(:user_id),
      phi_accesses: logs.where.not(phi_accessed: nil).count,
      actions_breakdown: logs.group(:action).count,
      most_active_users: logs.group(:user_id).count.sort_by { |_, v| -v }.first(10)
    }
  end
end
