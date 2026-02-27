# frozen_string_literal: true

# Fintech Compliance Concern
# PCI DSS and SOC2 compliance features
module FintechCompliance
  extend ActiveSupport::Concern

  included do
    before_action :log_access_attempt, if: :fintech_account?
    before_action :check_kyc_requirement, if: :requires_kyc?
    before_action :enforce_transaction_mfa, if: :transaction_requires_mfa?
  end

  private

  def fintech_account?
    current_account&.pci_compliant? || current_account&.soc2_compliant?
  end

  def requires_kyc?
    fintech_account? && params[:controller] =~ /transaction|payment/
  end

  def transaction_requires_mfa?
    current_account&.requires_mfa_for_transactions? && 
    params[:controller] =~ /transaction/ && 
    params[:action] =~ /create|update|destroy/
  end

  def log_access_attempt
    AccessControlLog.log_access_attempt(
      user: current_user,
      resource: controller_name,
      permission: action_name,
      granted: true
    )
  end

  def check_kyc_requirement
    unless current_user.kyc_verified_at
      redirect_to kyc_verification_path, alert: "KYC verification required for financial transactions"
    end
  end

  def enforce_transaction_mfa
    unless session[:mfa_verified_for_transaction]
      session[:return_to] = request.fullpath
      redirect_to two_factor_verify_path, alert: "MFA required for this transaction"
    end
  end

  def log_transaction(type, amount: nil, metadata: {})
    TransactionLog.log_transaction(
      user: current_user,
      account: current_account,
      type: type,
      amount: amount,
      metadata: metadata,
      request: request
    )
  end

  def log_security_event(type, severity: 'low', details: nil)
    SecurityEvent.log_event(
      type: type,
      severity: severity,
      user: current_user,
      details: details,
      request: request
    )
  end

  # PCI DSS: Check if user can perform transaction
  def within_transaction_limit?(amount)
    return true unless current_account.transaction_limit_daily

    today_total = TransactionLog
      .where(user: current_user, account: current_account)
      .where('created_at >= ?', Time.current.beginning_of_day)
      .sum(:amount)

    (today_total + amount) <= current_account.transaction_limit_daily
  end

  def check_aml_compliance
    unless current_user.aml_check_passed_at && current_user.aml_check_passed_at > 1.year.ago
      redirect_to aml_verification_path, alert: "AML verification required"
    end
  end
end
