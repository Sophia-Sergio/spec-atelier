describe Product, type: :model do
  let(:product) { create(:product) }

  describe 'factory built record' do
    it 'atteches a file' do
      image = create(:image)
      create(:resource_file, owner: product, attached: image)
      expect(product.images.length).to be(1)
    end
  end

  describe 'product associations' do
    it 'deletes its associated resources succesfully' do
      image = create(:image)
      create(:resource_file, owner: product, attached: image)
      create(:product_subitem, product: product)
      create(:product_item, product: product)
      create(:product_contact_form, owner: product)

      product.destroy

      expect(ProductSubitem.count).to be(0)
      expect(ProductItem.count).to be(0)
      expect(Attached::ResourceFile.count).to be(0)
      expect(Form::ProductContactForm.count).to be(0)
    end
  end
end
