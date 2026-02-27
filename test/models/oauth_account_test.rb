# frozen_string_literal: true

require "test_helper"

class OauthAccountTest < ActiveSupport::TestCase
  test "validates presence of provider and uid" do
    account = OauthAccount.new(provider: nil, uid: nil)
    assert_not account.valid?
    assert_includes account.errors[:provider], "can't be blank"
    assert_includes account.errors[:uid], "can't be blank"
  end

  test "validates uniqueness of uid per provider" do
    user = User.create!(email: "oauth@example.com", password: "password123", password_confirmation: "password123")
    OauthAccount.create!(user: user, provider: "google_oauth2", uid: "123")

    duplicate = OauthAccount.new(user: user, provider: "google_oauth2", uid: "123")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:uid], "has already been taken"
  end

  test "allows same uid for different providers" do
    user = User.create!(email: "multi@example.com", password: "password123", password_confirmation: "password123")
    OauthAccount.create!(user: user, provider: "google_oauth2", uid: "123")

    github = OauthAccount.new(user: user, provider: "github", uid: "123")
    assert github.valid?
  end

  test "encrypts access token" do
    user = User.create!(email: "token@example.com", password: "password123", password_confirmation: "password123")
    account = OauthAccount.create!(
      user: user,
      provider: "google_oauth2",
      uid: "unique-uid-#{SecureRandom.hex(4)}",
      access_token: "secret-token"
    )

    account.reload
    assert_equal "secret-token", account.access_token
    assert_not_equal "secret-token", account.read_attribute_before_type_cast(:access_token)
  end
end
