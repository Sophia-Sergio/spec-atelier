class BrandMailer < ApplicationMailer

  def send_contact_form_to_brand(current_user, form)
    @current_user = current_user
    @form = form
    @brand = @form.owner
    @brand_email = @brand.email
    mail(to: 'paul.eaton@specatelier.com', subject: 'Brand contact_form')
    mail(to: @current_user.email, subject: 'Brand contact_form')
  end

  def send_contact_form_to_user(current_user, form)
    @current_user = current_user
    @brand = form.owner
    @form = form
    mail(to: 'paul.eaton@specatelier.com', subject: 'Your mail was sent contact_form')
    mail(to: @current_user.email, subject: 'Your mail was sent contact_form')
  end
end
