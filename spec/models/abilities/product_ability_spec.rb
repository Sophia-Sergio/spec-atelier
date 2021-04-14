describe Abilities::ProductAbility, type: :model do
  describe 'brand' do
    let(:user) { create(:user) }
    let(:client) { create(:client) }

    context '#client_products' do
      before do
        create(:product, user: user)
        create(:product, client: client)
        create(:product)
      end

      context 'with client' do
        before do
          user.clients << client
          user.add_role(:client)
        end
        it 'fetchs brands he owns through products' do
          ability = Abilities::ProductAbility.new(user)
          expect(Product.accessible_by(ability, :client_products).count).to be(2)
        end
      end

      context 'with no client' do
        before { user.add_role(:client) }

        it 'fetchs brands he owns through products' do
          ability = Abilities::ProductAbility.new(user)
          expect(Product.accessible_by(ability, :client_products).count).to be(1)
        end
      end
    end
  end
end
