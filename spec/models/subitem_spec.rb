describe Subitem, type: :model do
  let(:item) { create(:item) }
  let(:subitem1) { create(:subitem, item: item) }
  let(:subitem2) { create(:subitem, item: item) }
  let(:subitem3) { create(:subitem, item: item) }

  context 'scopes' do
    before { create(:product, items: [item], subitems: [subitem1, subitem2]) }

    context '#with_products' do
      it 'return only subitems used on products' do
        expect(item.subitems.with_products.count).to be 2
      end
    end
  end
end
