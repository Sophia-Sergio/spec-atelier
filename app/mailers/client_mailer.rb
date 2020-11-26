class ClientMailer < ApplicationMailer

  def send_contact_form_to_client(current_user, form)
    @current_user = current_user
    @form = form
    @client = @form.owner
    @brand_email = @client.email
    mail(to: 'paul.eaton@specatelier.com', subject: 'SpecAtelier - Ha recibido un email de uno de nuestros usuarios')
  end

  def send_contact_form_to_user(current_user, form)
    @current_user = current_user
    @client = form.owner
    @form = form
    mail(to: @current_user.email, subject: "Tu email fue enviado correctamente a #{form.owner.name}")
  end
end
