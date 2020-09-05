class ProductMailer < ApplicationMailer

  def send_contact_form_to_brand(current_user, form)
    @current_user = current_user
    @form = form
    @product = @form.owner
    @brand = @product.brand
    @brand_email = @brand.email
    mail(to: @current_user.email, subject: 'Product contact_form')
  end

  def send_contact_form_to_user(current_user, form)
    @current_user = current_user
    @form = form
    @product = @form.owner
    @brand = @product.brand
    mail(to: @current_user.email, subject: 'Your mail was sent contact_form')
  end
end
