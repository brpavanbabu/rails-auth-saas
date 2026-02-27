# frozen_string_literal: true

# Fintech Compliance Concern
# PCI DSS and SOC2 compliance features.
#
# Prerequisites: your Account model should respond to
# `pci_compliant?` and/or `soc2_compliant?` to activate.
module FintechCompliance
  extend ActiveSupport::Concern

  included do
    before_action :log_fintech_access, if: :fintech_account?
  end

  private

  def fintech_account?
    return false unless current_user
    acct = current_account
    acct&.respond_to?(:pci_compliant?) && (acct.pci_compliant? || acct.soc2_compliant?)
  end

  def current_account
    @current_account ||= current_user&.accounts&.first
  end

  def log_fintech_access
    AccessControlLog.log_access_attempt(
      user: current_user,
      resource: controller_name,
      permission: action_name,
      granted: true
    )
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

  def log_security_event(type, severity: "low", details: nil)
    SecurityEvent.log_event(
      type: type,
      severity: severity,
      user: current_user,
      details: details,
      request: request
    )
  end

  def within_transaction_limit?(amount)
    return true unless current_account.respond_to?(:transaction_limit_daily)
    daily_limit = current_account.transaction_limit_daily
    return true unless daily_limit

    today_total = TransactionLog
      .where(user: current_user, account: current_account)
      .where("created_at >= ?", Time.current.beginning_of_day)
      .sum(:amount)

    (today_total + amount) <= daily_limit
  end
end
