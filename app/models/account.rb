# frozen_string_literal: true

class Account < ApplicationRecord
  has_many :account_memberships, dependent: :destroy
  has_many :users, through: :account_memberships
  has_many :saml_providers, dependent: :destroy

  validates :name, presence: true
end
