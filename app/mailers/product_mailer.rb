class ProductMailer < ApplicationMailer

  def send_contact_form_to_client(current_user, form)
    @current_user = current_user
    @form = form
    @product = @form.owner
    @client = @product.client
    @brand_email = @client.email
    mail(to: @current_user.email, subject: 'Product contact_form')
  end

  def send_contact_form_to_user(current_user, form)
    @current_user = current_user
    @form = form
    @product = @form.owner
    @client = @product.client
    mail(to: @current_user.email, subject: 'Your mail was sent contact_form')
  end
end
