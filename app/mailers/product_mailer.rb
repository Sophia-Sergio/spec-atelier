class ProductMailer < ApplicationMailer
  default from: 'paul.eaton@specatelier.com'

  def send_contact_form_to_brand(current_user, form)
    @current_user = current_user
    @form = form
    @product = @form.owner
    @brand = @product.brand
    @brand_email = @brand.email || 'jonathan.araya.m@gmail.com'
    mail(to: 'jonathan.araya.m@gmail.com' || @brand_email, subject: 'Product contact_form')
  end

  def send_contact_form_to_user(current_user, form)
    @current_user = current_user
    @form = form
    @product = @form.owner
    @brand = @product.brand
    # mail(to: @current_user.email || 'jonathan.araya.m@gmail.com', subject: 'Your mail was sent contact_form')
    mail(to: 'jonathan.araya.m@gmail.com' || 'jonathan.araya.m@gmail.com', subject: 'Your mail was sent contact_form')
  end
end
