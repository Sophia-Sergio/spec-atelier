class EmailWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(user = nil)
    puts 'start sending the email'
    UserMailer.test.deliver_later
  end
end
