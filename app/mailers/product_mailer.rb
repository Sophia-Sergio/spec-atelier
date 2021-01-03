class ProductMailer < ApplicationMailer

  def send_contact_form_to_client(current_user, form)
    @current_user = current_user
    @form = form
    @product = @form.owner
    @client = @product.client
    @brand_email = @client.email
    mail(to: @brand_email, subject: "SpecAtelier - A recibido una consulta sobre #{@product.name}")
  end

  def send_contact_form_to_user(current_user, form)
    @current_user = current_user
    @form = form
    @product = @form.owner
    @client = @product.client
    subject = "SpecAtelier - Hiciste una consulta a #{@client.name} sobre el producto #{@product.name}"
    mail(to: @current_user.email, subject: subject)
  end
end
