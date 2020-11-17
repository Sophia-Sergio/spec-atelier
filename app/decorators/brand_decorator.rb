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
           :contact_type,
           :logo

  def products_count
    model.products.count
  end

  def image
    model.logo_url
  end

  def email
    model.default_email
  end

  def country
    address_order0&.country
  end

  def logo
    model.logo_url
  end

  def web
    model.url
  end

  def address
    "#{address_order0&.text}, #{address_order0&.city}, #{address_order0&.country}"
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

  def address_order0
    @address_order0 ||= model.addresses&.find_by(order: 0)
  end
end
