describe Products::ProductSpecCreator, type: :model do
  let(:user) { create(:user, first_name: 'User B', email: 'userB@gmail.com') }
  let(:project) { create(:project, user: user, city: 'City B') }
  let(:product) { create(:product, user: user, items: [item1, item2], name: 'Product A') }
  let(:section) { create(:section) }
  let(:item1) { create(:item, show_order: 2, section: section) }
  let(:item2) { create(:item, show_order: 1, section: section) }
  let(:service)  { Products::ProductSpecCreator.call(params, nil, product, project_spec: project.specification) }

  context '#call' do
    let(:params) { { item: [item1.id, item2.id] } }
    let(:product_spec) { Product.find_by(original_product_id: product.id) }

    before { service }

    context 'when needs to be in two items' do
      it 'sets two times the same products in the right order' do
        expect(project.specification.blocks[0].spec_item).to eq section
        expect(project.specification.blocks[1].spec_item).to eq item2
        expect(project.specification.blocks[2].spec_item).to eq product_spec
        expect(project.specification.blocks[3].spec_item).to eq item1
        expect(project.specification.blocks[4].spec_item).to eq product_spec
      end
    end
  end
end
