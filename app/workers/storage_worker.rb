class StorageWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(product, images)
    GoogleStorage.new(product, images).perform
  end
end
