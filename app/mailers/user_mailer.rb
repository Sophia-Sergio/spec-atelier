class UserMailer < ApplicationMailer
  default from: 'paul.eaton@specatelier.com'

  def send_signup_email(user)
    @user = user
    # mail(to: user.email, subject: 'Thanks for signing up for our amazing app')
    mail(to: 'jonathan.araya.m@gmail.com', subject: 'Thanks for signing up for our amazing app')
  end

  def password_reset(user)
    @user = user
    mail(to: user.email, subject: 'Reset password')
  end
end
