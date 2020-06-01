class BrandMailer < ApplicationMailer
  default from: 'paul.eaton@specatelier.com'

  def send_contact_form_to_brand(current_user, form)
    @current_user = current_user
    @form = form
    @brand = @form.brand
    from = @brand.email['main']
    mail(from: from, to: @brand.email, subject: 'Brand contact_form')
  end

  def send_contact_form_to_user(current_user, form)
    @current_user = current_user
    @brand = form.brand
    mail(to: @current_user.email, subject: 'Your mail was sended contact_form')
  end
end
