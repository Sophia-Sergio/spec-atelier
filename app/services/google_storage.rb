require 'google/cloud/storage'

class GoogleStorage
  def initialize(owner, file)
    @owner = owner
    @file = file
  end

  def perform
    upload_file(@file)
  end

  private

  def client_name
    @owner.client.name
  end
  
  def upload_file(file)
    storage_bucket.upload_file(file.tempfile, "images/#{client_name}-#{file.original_filename}")
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
