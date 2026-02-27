# frozen_string_literal: true

# Transaction Log Model - PCI DSS Compliance
class TransactionLog < ApplicationRecord
  belongs_to :user
  belongs_to :account

  validates :transaction_type, :transaction_id, presence: true

  encrypts :metadata if Rails.application.credentials.secret_key_base.present?

  scope :recent, -> { order(created_at: :desc) }
  scope :suspicious_transactions, -> { where(suspicious: true) }
  scope :for_date_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }

  # PCI DSS Requirement: Log all transactions
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
      risk_score: calculate_risk_score(user, amount, request),
      suspicious: detect_suspicious_pattern(user, amount, request)
    )
  end

  # Risk scoring for AML compliance
  def self.calculate_risk_score(user, amount, request)
    score = 0
    score += 20 if amount && amount > 10000
    score += 10 if user.risk_level == 'high'
    score += 15 if unusual_location?(user, request)
    score += 10 if unusual_time?
    { score: score, level: score > 50 ? 'high' : (score > 25 ? 'medium' : 'low') }.to_json
  end

  def self.detect_suspicious_pattern(user, amount, request)
    # Check for rapid transactions
    recent_count = where(user: user).where('created_at > ?', 5.minutes.ago).count
    return true if recent_count > 10

    # Check for large amounts
    return true if amount && amount > (user.transaction_limit || 50000)

    false
  end

  def self.unusual_location?(user, request)
    return false unless request
    # Compare with user's usual locations (simplified)
    last_locations = where(user: user).where('created_at > ?', 7.days.ago).pluck(:ip_address).uniq
    !last_locations.include?(request.remote_ip) && last_locations.count > 3
  end

  def self.unusual_time?
    hour = Time.current.hour
    hour < 6 || hour > 22 # Outside 6 AM - 10 PM
  end

  def self.calculate_device_fingerprint(request)
    return nil unless request
    Digest::SHA256.hexdigest("#{request.user_agent}#{request.remote_ip}")[0..15]
  end

  # PCI DSS Compliance Report
  def self.pci_compliance_report(account_id, period: 90.days)
    transactions = where(account_id: account_id).where('created_at > ?', period.ago)
    
    {
      total_transactions: transactions.count,
      suspicious_count: transactions.suspicious_transactions.count,
      total_volume: transactions.sum(:amount),
      unique_users: transactions.distinct.count(:user_id),
      high_risk_transactions: transactions.where("risk_score->>'level' = ?", 'high').count,
      compliance_issues: identify_compliance_issues(transactions)
    }
  end

  def self.identify_compliance_issues(transactions)
    issues = []
    issues << "High volume of suspicious transactions" if transactions.suspicious_transactions.count > transactions.count * 0.1
    issues << "Unusual transaction patterns detected" if detect_unusual_patterns(transactions)
    issues
  end

  def self.detect_unusual_patterns(transactions)
    # Simplified pattern detection
    transactions.group_by_day(:created_at).count.values.max > 1000
  end
end
