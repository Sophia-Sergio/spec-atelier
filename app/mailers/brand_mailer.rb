class BrandMailer < ApplicationMailer
  default from: 'paul.eaton@specatelier.com'

  def send_contact_form_to_brand(current_user, form)
    @current_user = current_user
    @form = form
    @brand = @form.owner
    @brand_email = @brand.email['main'] || 'jonathan.araya.m@gmail.com'
    mail(to: @brand_email, subject: 'Brand contact_form')
    mail(to: 'jonathan.araya.m@gmail.com', subject: 'Brand contact_form')
  end

  def send_contact_form_to_user(current_user, form)
    @current_user = current_user
    @brand = form.owner
    mail(to: @current_user.email, subject: 'Your mail was sent contact_form')
  end
end
