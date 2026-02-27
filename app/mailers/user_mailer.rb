# frozen_string_literal: true

class UserMailer < ApplicationMailer
  def magic_link(user, token)
    @user = user
    @url = magic_link_verify_url(token)
    mail(to: user.email, subject: "Your magic sign-in link")
  end

  def verify_email(user, token)
    @user = user
    @url = verify_email_url(token)
    mail(to: user.email, subject: "Verify your email")
  end
end
