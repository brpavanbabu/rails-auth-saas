# frozen_string_literal: true

# HIPAA Compliance Concern
# Include in ApplicationController to enable HIPAA audit logging.
#
# Prerequisites: your Account model must respond to `hipaa_enabled?`
# and your User model should have `session_timeout_minutes` (default: 15).
module HipaaCompliance
  extend ActiveSupport::Concern

  included do
    before_action :log_request_for_hipaa, if: :hipaa_enabled?
    after_action :check_session_timeout, if: :hipaa_enabled?
  end

  private

  def hipaa_enabled?
    return false unless current_user
    current_account&.respond_to?(:hipaa_enabled?) && current_account.hipaa_enabled?
  end

  def current_account
    @current_account ||= current_user&.accounts&.first
  end

  def log_request_for_hipaa
    AuditLog.log_action(
      user: current_user,
      account: current_account,
      action: "#{controller_name}##{action_name}",
      request: request
    )
  end

  def check_session_timeout
    return unless current_user

    timeout_minutes = if current_user.respond_to?(:session_timeout_minutes)
                        current_user.session_timeout_minutes || 15
    else
                        15
    end

    last_activity = session[:last_activity_at]

    if last_activity && Time.current > Time.parse(last_activity.to_s) + timeout_minutes.minutes
      reset_session
      redirect_to login_path, alert: "Session expired for security (HIPAA compliance)"
    else
      session[:last_activity_at] = Time.current.iso8601
    end
  end

  def log_phi_access(data_type, action, justification = nil)
    DataAccessLog.log_phi_access(
      user: current_user,
      account: current_account,
      action: action,
      justification: justification,
      request: request
    )
  end
end
