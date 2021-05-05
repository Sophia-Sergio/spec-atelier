describe Subitem, type: :model do
  let(:user1) { create(:user) }
  let(:user2) { create(:user) }
  let(:item) { create(:item) }
  let(:subitem1) { create(:subitem, item: item) }
  let(:subitem2) { create(:subitem, item: item) }
  let(:subitem3) { create(:subitem, item: item ) }

  context 'scopes' do
    before { create(:product, items: [item], subitems: [subitem1, subitem2], user: user2) }

    context '#with_products' do
      it 'return only subitems used on products' do
        expect(item.subitems.with_products.count).to be 2
      end
    end

    context '#with_accessible_products' do
      before { create(:product, items: [item], subitems: [subitem1], user: user1) }

      it 'return only subitems used on products accessible by user' do
        expect(item.subitems.with_accessible_products(user1).count).to be 1
        expect(item.subitems.with_accessible_products(user1).first).to eq subitem1
      end
    end
  end
end
