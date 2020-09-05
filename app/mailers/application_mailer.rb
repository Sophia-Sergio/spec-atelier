class ApplicationMailer < ActionMailer::Base
  EMAILS_WITH_COPY = %w[jonathan.araya.m@gmail.com paul.eaton@specatelier.com san.storres@gmail.com].freeze

  layout 'mailer'

  default from: 'paul.eaton@specatelier.com'
  default bbc: EMAILS_WITH_COPY
end
