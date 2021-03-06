class UserMailer < ApplicationMailer

  def send_signup_email(user)
    @user = user
    mail(to: @user.email, subject: 'Thanks for signing up for our amazing app')
  end

  def password_reset(user)
    @user = user
    mail(to: @user.email, subject: 'Reset password')
  end

  def password_reset_success(user)
    @user = user
    mail(to: @user.email, subject: 'New Password')
  end
end
