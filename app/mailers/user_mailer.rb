class UserMailer < ApplicationMailer
  EMAILS_WITH_COPY = %w[jonathan.araya.m@gmail.com paul.eaton@specatelier.com san.storres@gmail.com].freeze

  default from: 'paul.eaton@specatelier.com'
  default bbc: EMAILS_WITH_COPY

  def send_signup_email(user)
    @user = user
    mail(to: user.email, subject: 'Thanks for signing up for our amazing app')
  end

  def password_reset(user)
    @user = user
    mail(to: user.email, subject: 'Reset password')
  end

  def test
    mail(to: 'san.storres@gmail.com', subject: 'Reset password1')
  end

  def password_reset_success(user)
    @user = user
    mail(to: user.email, subject: 'New Password')
  end
end
