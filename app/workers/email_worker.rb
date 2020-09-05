class EmailWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user, type)
    case type
    when 'password_reset' then UserMailer.password_reset(user).deliver_later
    when 'password_reset_success' then UserMailer.password_reset(user).deliver_later
    when 'send_signup_email' then UserMailer.send_signup_email(user).deliver_later
    end
  end
end
