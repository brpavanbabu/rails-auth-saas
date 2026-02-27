# frozen_string_literal: true

# HIPAA Compliance Concern
# Include in ApplicationController to enable HIPAA audit logging
module HipaaCompliance
  extend ActiveSupport::Concern

  included do
    before_action :log_request_for_hipaa, if: :hipaa_enabled?
    after_action :check_session_timeout, if: :hipaa_enabled?
  end

  private

  def hipaa_enabled?
    current_user&.accounts&.any?(&:hipaa_enabled?)
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

    timeout_minutes = current_user.session_timeout_minutes || 15
    last_activity = session[:last_activity_at]&.to_time

    if last_activity && Time.current > last_activity + timeout_minutes.minutes
      reset_session
      redirect_to login_path, alert: "Session expired for security (HIPAA compliance)"
    else
      session[:last_activity_at] = Time.current
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

  def require_hipaa_training
    unless current_user.hipaa_trained_at && current_user.hipaa_trained_at > 1.year.ago
      redirect_to hipaa_training_path, alert: "HIPAA training required"
    end
  end

  def require_password_change_check
    if current_user.force_password_change
      redirect_to change_password_path, alert: "Password change required for compliance"
    end
  end
end
