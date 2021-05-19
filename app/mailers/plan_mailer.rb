class PlanMailer < ApplicationMailer

  def send_contact_form_to_client(form)
    @form = form
    @brand_email = @form.email
    mail(to: @brand_email, subject: "SpecAtelier - Tu consulta por el plan ha sido recibida")
  end

  def send_contact_form_to_spec(form)
    @form = form
    mail(to: 'contacto@specatelier.com', subject: "SpecAtelier - Alguien quiere unirse!")
  end
end
