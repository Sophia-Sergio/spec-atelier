require 'google/cloud/storage'

class GoogleStorage
  def initialize(owner, files)
    @files = files
    @owner = owner
  end

  def perform
    to_array_of_files.map do |file|
      file_stored = upload_file(file)
      attach_to_owner(file_stored)
    end
  end

  private

  def to_array_of_files
    @files.is_a?(Array) ? @files : [@files]
  end

  def upload_file(file)
    storage_bucket.upload_file(file.tempfile, "images/#{brand_name}-#{file.original_filename}")
  end

  def brand_name
    @owner.brand.name
  end

  def attach_to_owner(file_stored)
    case true
    when @owner.is_a?(Product) then attach_to_product(file_stored)
    end
  end

  def attach_to_product(file_stored)
    name_stored_file = file_stored.name.gsub('images/','')
    case file_stored.content_type.split('/').first
    when 'image'
      image = Attached::Image.create!(url: file_stored.public_url, name: name_stored_file)
      create_resourse_file(image)
    else
      document = Attached::Document.create!(url: file_stored.public_url, name: name_stored_file)
      create_resourse_file(document)
    end
  end

  def create_resourse_file(image)
    Attached::ResourceFile.create!(owner: @owner, attached: image)
  end

  def storage_bucket
    @storage_bucket ||= begin
      File.open('config/google_storage_config.json', 'w') {|f| f.write(ENV['GOOGLE_APPLICATION_CREDENTIALS']) }
      storage = Google::Cloud::Storage.new(
        project_id:  "spec-atelier",
        credentials: 'config/google_storage_config.json'
      )
      storage.bucket(ENV['GOOGLE_BUCKET_IMAGES'])
    end
  end
end
