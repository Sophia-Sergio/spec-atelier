require 'google/cloud/storage'

class GoogleStorage
  def initialize(owner, file, kind)
    @owner = owner
    @file = file
    @kind = kind
  end

  def upload(name = nil)
    upload_file(@file, name)
  end

  def remove(name = nil)
    remove_file(name)
  end

  private

  def file_name
    (@owner.client&.name || @owner.brand&.name) + "-#{@file.original_filename}"
  end

  def upload_file(file, name)
    file = file.respond_to?(:tempfile) ? file.tempfile : file
    name ||= file_name
    storage_bucket.upload_file(file, storage_path(name))
  end

  def storage_path(name)
    "#{@kind.pluralize}/#{name}"
  end

  def remove_file(name)
    storage_bucket.file(storage_path(name))&.delete
    storage_bucket.file(storage_path("resized-medium-#{name}"))&.delete
    storage_bucket.file(storage_path("resized-small-#{name}"))&.delete
    storage_bucket.file(storage_path("resized-thumb-#{name}"))&.delete
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
