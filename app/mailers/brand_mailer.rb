class BrandMailer < ApplicationMailer

  def send_contact_form_to_brand(current_user, form)
    @current_user = current_user
    @form = form
    @brand = @form.owner
    @brand_email = @brand.email
    mail(to: 'paul.eaton@specatelier.com', subject: 'SpecAtelier - Ha recibido un email de uno de nuestros usuarios')
  end

  def send_contact_form_to_user(current_user, form)
    @current_user = current_user
    @brand = form.owner
    @form = form
    mail(to: @current_user.email, subject: "Tu email fue enviado correctamente a #{form.owner}")
  end
end
