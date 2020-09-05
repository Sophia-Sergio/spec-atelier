class FileUploadJob < ApplicationJob
  queue_as :low_priority

  def perform
    puts 'hola'
  end

end