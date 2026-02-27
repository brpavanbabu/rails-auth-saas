require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "valid user with email and password" do
    user = User.new(email: "user@example.com", password: "password123", password_confirmation: "password123")
    assert user.valid?
  end

  test "invalid without email" do
    user = User.new(email: nil, password: "password123", password_confirmation: "password123")
    assert_not user.valid?
    assert_includes user.errors[:email], "can't be blank"
  end

  test "invalid with duplicate email case insensitive" do
    User.create!(email: "user@example.com", password: "password123", password_confirmation: "password123")
    user = User.new(email: "USER@EXAMPLE.COM", password: "password456", password_confirmation: "password456")
    assert_not user.valid?
    assert_includes user.errors[:email], "has already been taken"
  end

  test "invalid with bad email format" do
    user = User.new(email: "not-an-email", password: "password123", password_confirmation: "password123")
    assert_not user.valid?
    assert user.errors[:email].any? { |msg| msg.include?("invalid") }
  end

  test "invalid password too short" do
    user = User.new(email: "user@example.com", password: "short", password_confirmation: "short")
    assert_not user.valid?
    assert user.errors[:password].any? { |msg| msg.include?("too short") }
  end

  test "email normalized on save" do
    user = User.create!(email: "USER@Example.COM", password: "password123", password_confirmation: "password123")
    assert_equal "user@example.com", user.reload.email
  end

  test "password authentication works" do
    user = User.create!(email: "user@example.com", password: "secret123", password_confirmation: "secret123")
    assert user.authenticate("secret123")
    assert_not user.authenticate("wrongpassword")
  end
end
