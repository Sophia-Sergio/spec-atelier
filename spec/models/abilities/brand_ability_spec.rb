describe Abilities::BrandAbility, type: :model do
  describe 'brand' do
    let(:user) { create(:user) }

    context '#index' do
      before do
        create_list(:brand, 2, :with_client)
        create_list(:brand, 2)
        create_list(:product, 2, user: user)
      end

      it 'fetchs brands he owns through products' do
        ability = Abilities::BrandAbility.new(user)
        expect(Brand.accessible_by(ability).count).to be(4)
      end
    end
  end
end
