class ApplicationMailer < ActionMailer::Base
  EMAILS_WITH_COPY = %w[jonathan.araya.m@gmail.com paul.eaton@specatelier.com san.storres@gmail.com].freeze

  layout 'mailer'

  default from: 'contacto@specatelier.com'
  default bbc: EMAILS_WITH_COPY
end
