module AssociateFiles
  extend ActiveSupport::Concern

  def associate_files(product, files)
    to_array_of_files(files).each do |file|
      file_stored = GoogleStorage.new(product, file).perform
      attach_to_owner(product, file_stored)
    end
  end

  private

  def to_array_of_files(files)
    files.is_a?(Array) ? files : [files]
  end

  def attach_to_owner(product, file_stored)
    case true
    when product.is_a?(Product) then attach_to_product(product, file_stored)
    end
  end

  def attach_to_product(product, file_stored)
    name_stored_file = file_stored.name.gsub('images/','')
    case file_stored.content_type.split('/').first
    when 'image'
      image = Attached::Image.create!(url: file_stored.public_url, name: name_stored_file)
      create_resourse_file(product, image, 'product_image')
    else
      document = Attached::Document.create!(url: file_stored.public_url, name: name_stored_file)
      create_resourse_file(product, document, 'product_document')
    end
  end

  def create_resourse_file(owner, image, kind)
    Attached::ResourceFile.create!(owner: owner, attached: image, kind: kind)
  end
end
