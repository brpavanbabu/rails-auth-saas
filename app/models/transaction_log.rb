# frozen_string_literal: true

class TransactionLog < ApplicationRecord
  belongs_to :user
  belongs_to :account

  validates :transaction_type, :transaction_id, presence: true

  encrypts :metadata

  scope :recent, -> { order(created_at: :desc) }
  scope :suspicious_transactions, -> { where(suspicious: true) }
  scope :for_date_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  def self.log_transaction(user:, account:, type:, amount: nil, metadata: {}, request: nil)
    create!(
      user: user,
      account: account,
      transaction_type: type,
      transaction_id: SecureRandom.uuid,
      amount: amount,
      metadata: metadata.to_json,
      ip_address: request&.remote_ip,
      device_fingerprint: calculate_device_fingerprint(request),
      risk_score: calculate_risk_score(amount, request),
      suspicious: detect_suspicious_pattern(user, amount)
    )
  end

  def self.calculate_risk_score(amount, request)
    score = 0
    score += 20 if amount && amount > 10_000
    score += 15 if request && unusual_time?
    { score: score, level: score > 50 ? "high" : (score > 25 ? "medium" : "low") }.to_json
  end

  def self.detect_suspicious_pattern(user, amount)
    recent_count = where(user: user).where("created_at > ?", 5.minutes.ago).count
    return true if recent_count > 10
    return true if amount && amount > 50_000
    false
  end

  def self.unusual_time?
    hour = Time.current.hour
    hour < 6 || hour > 22
  end

  def self.calculate_device_fingerprint(request)
    return nil unless request
    Digest::SHA256.hexdigest("#{request.user_agent}#{request.remote_ip}")[0..15]
  end

  def self.pci_compliance_report(account_id, period: 90.days)
    transactions = where(account_id: account_id).where("created_at > ?", period.ago)

    {
      total_transactions: transactions.count,
      suspicious_count: transactions.suspicious_transactions.count,
      total_volume: transactions.sum(:amount),
      unique_users: transactions.distinct.count(:user_id)
    }
  end
end
