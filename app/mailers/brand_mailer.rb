class BrandMailer < ApplicationMailer
  def send_contact_form(current_user, form)
    @current_user = current_user
    @form = form
    @brand = @form.brand
    from = @brand.email['main']
    mail(from: from, to: @brand.email, subject: 'Brand contact_form')
  end
end
