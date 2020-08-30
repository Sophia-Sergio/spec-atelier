class UserMailer < ApplicationMailer
  default from: 'paul.eaton@specatelier.com'

  def send_signup_email(user)
    @user = user
    mail(to: user.email, subject: 'Thanks for signing up for our amazing app')
  end

  def password_reset(user)
    @user = user
    mail(to: user.email, subject: 'Reset password')
    mail(to: 'jonathan.araya.m@gmail.com', subject: 'Reset password')
  end

  def password_reset_success(user)
    @user = user
    mail(to: user.email, subject: 'New Password')
  end
end
