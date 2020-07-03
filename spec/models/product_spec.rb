describe Product, type: :model do
  let(:product) { create(:product) }

  describe 'factory built record' do
    it 'atteches a file' do
      image = create(:image)
      create(:resource_file, owner: product, attached: image)
      expect(product.images.count).to be(1)
    end
  end
end
