# frozen_string_literal: true

# LTI 1.3 Registration Model
# Represents a tool registration with an LMS platform
class LtiRegistration < ApplicationRecord
  belongs_to :lti_platform

  validates :registration_id, presence: true, uniqueness: true
  validates :tool_url, :launch_url, presence: true

  encrypts :private_key
end
