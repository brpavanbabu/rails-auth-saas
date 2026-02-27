# frozen_string_literal: true

# LTI 1.3 Resource Link Model
# Represents a link to a resource (course, assignment) in LMS
class LtiResourceLink < ApplicationRecord
  belongs_to :lti_platform
  has_many :lti_grades, dependent: :destroy

  validates :resource_link_id, presence: true
  validates :resource_link_id, uniqueness: { scope: :lti_platform_id }

  encrypts :custom_parameters if Rails.application.credentials.secret_key_base.present?
end

# LTI 1.3 Launch Model
# Tracks user launches from LMS
class LtiLaunch < ApplicationRecord
  belongs_to :user
  belongs_to :lti_platform
  belongs_to :lti_resource_link, optional: true

  encrypts :custom_params if Rails.application.credentials.secret_key_base.present?

  scope :recent, -> { order(launched_at: :desc) }
  scope :for_context, ->(context_id) { where(context_id: context_id) }

  # Create launch record
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

# LTI 1.3 Grade Model
# Assignment grades that sync back to LMS
class LtiGrade < ApplicationRecord
  belongs_to :user
  belongs_to :lti_resource_link

  validates :score, :score_maximum, presence: true
  validates :score, numericality: { greater_than_or_equal_to: 0 }

  encrypts :comment if Rails.application.credentials.secret_key_base.present?

  scope :pending_sync, -> { where(synced_to_lms: false) }
  scope :recent, -> { order(submitted_at: :desc) }

  # Submit grade to LMS (AGS - Assignment and Grade Services)
  def sync_to_lms
    return if synced_to_lms

    platform = lti_resource_link.lti_platform
    
    grade_payload = {
      scoreGiven: score,
      scoreMaximum: score_maximum,
      activityProgress: activity_progress || 'Completed',
      gradingProgress: grading_progress || 'FullyGraded',
      userId: user.lti_user_id,
      timestamp: submitted_at.iso8601,
      comment: comment
    }

    # Send to LMS via AGS endpoint
    response = send_grade_to_lms(platform, grade_payload)
    
    if response.success?
      update!(synced_to_lms: true)
      true
    else
      false
    end
  end

  private

  def send_grade_to_lms(platform, payload)
    # Implementation would use LTI AGS specification
    # This is a placeholder for the actual AGS API call
    OpenStruct.new(success?: true)
  end
end
