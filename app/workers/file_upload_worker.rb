class FileUploadWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(product_id)
    product = Product.find(product_id)
    Image.where(owner: product).each do |image|
      image.thumb
      image.small
      image.medium
    end
  end
end
