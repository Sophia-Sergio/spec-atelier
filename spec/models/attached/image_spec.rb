describe Attached::Image, type: :model do
  describe 'create image' do
    let(:product) { create(:product) }

    it 'should creates an image' do
      create(:image, owner: product)
      create(:image, owner: product)
      expect(Attached::Image.count).to be 2
    end
  end

  describe 'validates before saving' do
    let(:product) { create(:product) }
    let(:product2) { create(:product) }

    it 'should not be allowed to create images with the same name for the same owner' do
      create(:image, owner: product, name: 'same')
      expect(build(:image, owner: product, name: 'same')).to have(1).error_on(:name)
    end
  end
end
