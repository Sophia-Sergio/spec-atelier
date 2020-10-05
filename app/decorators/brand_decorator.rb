class BrandDecorator < ApplicationDecorator
  delegate :id, :name, :description

  new_keys :products_count,
           :address,
           :country,
           :phone,
           :web,
           :email,
           :social_media,
           :product_images,
           :contact_type

  def products_count
    model.products.count
  end

  def description
    "<p><strong>Pellentesque habitant morbi tristique</strong> senectus et netus et malesuada fames ac turpis egestas. Vestibulum tortor quam, feugiat vitae, ultricies eget, tempor sit amet, ante. Donec eu libero sit amet quam egestas semper. <em>Aenean ultricies mi vitae est.</em> Mauris placerat eleifend leo. Quisque sit amet est et sapien ullamcorper pharetra. Vestibulum erat wisi, condimentum sed, <code>commodo vitae</code>, ornare sit amet, wisi. Aenean fermentum, elit eget tincidunt condimentum, eros ipsum rutrum orci, sagittis tempus lacus enim ac dui</p>"
  end

  def image
    model.logo_url
  end

  def email
    model.default_email
  end

  def country
    'Chile'
  end

  def web
    model.url
  end

  def address
    "#{address_order_0&.text}, #{address_order_0&.city}, #{address_order_0&.country}"
  end

  def social_media
    model.social_media&.map {|key, value| { name: key, url: value } }
  end

  def phone
    model.phone['main']
  end

  def contact_type
    model.contact_info
  end

  def product_images
    model.product_images.map {|image| { id: image.id, url: image.all_formats[:medium] } }
  end

  private

  def address_order_0
    @address_order_0 ||= model.addresses&.find_by(order: 0)
  end
end

