describe Attached::Image, type: :model do
  describe 'create image' do
    let(:product) { create(:product) }

    it 'should creates an image' do
      create(:image)
      create(:image)
      expect(Attached::Image.count).to be 2
    end
  end
end
