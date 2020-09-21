class StorageWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(product, images, kind)
    GoogleStorage.new(product, images, kind).perform
  end
end
