# frozen_string_literal: true

class LtiResourceLink < ApplicationRecord
  belongs_to :lti_platform

  validates :resource_link_id, presence: true
  validates :resource_link_id, uniqueness: { scope: :lti_platform_id }

  encrypts :custom_parameters
end

class LtiLaunch < ApplicationRecord
  belongs_to :user
  belongs_to :lti_platform
  belongs_to :lti_resource_link, optional: true

  encrypts :custom_params

  scope :recent, -> { order(launched_at: :desc) }
  scope :for_context, ->(context_id) { where(context_id: context_id) }

  def self.log_launch(user:, platform:, resource_link: nil, lti_user_id:, context_id:, role:, params: {})
    create!(
      user: user,
      lti_platform: platform,
      lti_resource_link: resource_link,
      lti_user_id: lti_user_id,
      context_id: context_id,
      role: role,
      custom_params: params.to_json,
      launched_at: Time.current
    )
  end
end

class LtiGrade < ApplicationRecord
  belongs_to :user
  belongs_to :lti_resource_link

  validates :score, :score_maximum, presence: true
  validates :score, numericality: { greater_than_or_equal_to: 0 }

  encrypts :comment

  scope :pending_sync, -> { where(synced_to_lms: false) }
  scope :recent, -> { order(submitted_at: :desc) }

  def sync_to_lms
    return if synced_to_lms

    platform = lti_resource_link.lti_platform

    grade_payload = {
      scoreGiven: score,
      scoreMaximum: score_maximum,
      activityProgress: activity_progress || "Completed",
      gradingProgress: grading_progress || "FullyGraded",
      userId: user.lti_user_id,
      timestamp: submitted_at.iso8601,
      comment: comment
    }

    if send_grade_to_lms(platform, grade_payload)
      update!(synced_to_lms: true)
      true
    else
      false
    end
  end

  private

  def send_grade_to_lms(platform, payload)
    # Implement LTI AGS (Assignment and Grade Services) API call here.
    # See: https://www.imsglobal.org/spec/lti-ags/v2p0
    Rails.logger.info "Grade sync requested for resource_link #{lti_resource_link_id}: #{payload.to_json}"
    true
  end
end
