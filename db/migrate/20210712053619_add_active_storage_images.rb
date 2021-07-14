require 'open-uri'
class AddActiveStorageImages < ActiveRecord::Migration[6.1]

  KINDS_EXCEPT_DOCUMENTS = %w[product_image profile_image item_image logo brand_show].freeze

  def change
    create_documents
    [Product, Client, User, Item].each {|class_name| from_resource_file_to_images(class_name)}
  end

  def from_resource_file_to_images(model)
    model.all.each do |resource|
      Attached::ResourceFile.where(owner: resource, kind: KINDS_EXCEPT_DOCUMENTS).order(:order)
                            .each_with_index do |resource_file, index|
        case true
        when [Product, Client].include?(resource.class)
          attach_image(resource_file, resource, index) if %w[brand_show product_image].include? resource_file.kind
          attach_one_image(resource_file, resource, :logo) if resource_file.kind == 'logo'
        when resource.class == User
          attach_one_image(resource_file, resource, :profile_photo)
        when resource.class == Item
          attach_one_image(resource_file, resource, :default_image)
        end
      end
    end
  end

  private

  def create_documents
    Product.all.each do |resource|
      documents = Attached::ResourceFile.where(owner: resource, kind: 'product_document').map do |resource_file|
        {io: open(resource_file.attached.url), filename: resource_file.attached.name }
      end
      attach_documents(resource, documents)
    end
  end

  def attach_one_image(resource_file, resource, attached)
    image_name = resource_file.attached.name
    file = open(resource_file.attached.url)
    resource.send(attached).attach(io: file, filename: image_name)
  end

  def attach_documents(resource, documents)
    resource.docs.attach(documents)
  end

  def attach_image(resource_file, owner, index)
    return if resource_file.attached.url.include? " "
    file = open(resource_file.attached.url)
    image_name = resource_file.attached.name
    image_model = Image.create(order: index, owner: owner)
    image_model.file.attach(io: file, filename: image_name)
    FileUploadWorker.perform_async(owner.id) if owner.class == Product
  end
end
