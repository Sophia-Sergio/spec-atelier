require 'google/cloud/storage'

class GoogleStorage
  def initialize(owner, files)
    @files = files
    @owner = owner
  end

  def perform
    to_array_of_files.each do |file|
      file_stored = upload_file(file)
      attach_to_owner(file, file_stored)
    end
  end

  private

  def to_array_of_files
    @files.is_a?(Array) ? @files : [@files]
  end

  def upload_file(file)
    storage_bucket.upload_file(file.tempfile, "#{folder}/#{owner_name}-#{file.original_filename}")
  end

  def owner_name
    @owner.brand.name
  end

  def folder
    @owner.class.to_s.pluralize.underscore
  end

  def attach_to_owner(file_uploaded, file_stored)
    case true
    when @owner.is_a?(Product) then attach_to_product(file_uploaded, file_stored)
    end
  end

  def attach_to_product(file_uploaded, file_stored)
    case file_stored.content_type.split('/').first
    when 'image'
      Attached::Image.create!(owner: @owner, url: file_stored.public_url, name: file_uploaded.original_filename)
    else
      Attached::Document.create!(owner: @owner, url: file_stored.public_url, name: file_uploaded.original_filename)
    end
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
