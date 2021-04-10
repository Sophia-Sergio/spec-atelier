describe Product, type: :model do
  let(:product) { create(:product) }
  let(:product_used_on_spec) { create(:product, :used_on_spec) }

  describe 'factory built record' do
    it 'attaches a file' do
      image = create(:image)
      create(:resource_file, owner: product, attached: image)
      expect(product.images.length).to be(1)
    end
  end

  describe '#create_stats' do
    context 'when is original' do
      it 'creates a stats when product is created' do
        expect(product.stats.present?).to be true
      end
    end

    context 'when is used_on_spec' do
      it 'creates a stats when product is created' do
        expect(product_used_on_spec.stats.present?).to be false
      end
    end
  end

  describe '#used_on_spec_stat_update' do
    context 'if product_stat does not exists' do
      it 'created a record on stats' do
        create(:product, :used_on_spec, original_product_id: product.id)
        expect(product.reload.stats_used_on_spec).to be 1
      end
    end

    context 'if product_stat does exists' do
      it 'created a record on stats' do
        create(:product, :used_on_spec, original_product_id: product.id)
        create(:product, :used_on_spec, original_product_id: product.id)
        expect(product.reload.stats_used_on_spec).to be 2
      end
    end
  end

  describe '#used_on_spec_stat_update' do
    it 'updated the counter -1' do
      product_spec = create(:product, :used_on_spec, original_product_id: product.id)
      expect(product.reload.stats_used_on_spec).to be 1
      product_spec.destroy
      expect(product.reload.stats_used_on_spec).to be 0
    end
  end

  describe '#destroy' do
    it 'destroys product stats' do
      create(:product, :used_on_spec, original_product_id: product.id)
      product.destroy
      expect(ProductStat.find_by(product: product).present?).to be false
    end
  end

  describe '#readable_by' do
    let(:user) { create(:user) }
    let(:user_superadmin) { create(:user, roles: [role]) }
    let(:role) { create(:role, name: 'superadmin') }

    before do
      create_list(:product, 2, user: user_superadmin)
      create_list(:product, 2, user: user)
      create_list(:product, 2, user: create(:user))
    end

    it 'fetch only products created by the system original + created by the user' do
      expect(Product.readable_by(user).count).to be(4)
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

  describe 'original_product' do
    it 'brings the original_product' do
      product = create(:product, :used_on_spec)
      expect(product.original_product.class).to eq(Product)
    end
  end

  describe 'most_used' do
    it 'brings the original_product orderer by times used in specifications' do
      original_product1 = create(:product)
      original_product2 = create(:product)
      original_product3 = create(:product)
      create(:product, :used_on_spec, original_product_id: original_product1.id)
      create(:product, :used_on_spec, original_product_id: original_product2.id)
      create(:product, :used_on_spec, original_product_id: original_product2.id)
      create(:product, :used_on_spec, original_product_id: original_product2.id)
      create(:product, :used_on_spec, original_product_id: original_product3.id)
      create(:product, :used_on_spec, original_product_id: original_product3.id)

      most_used = Product.most_used

      expect(most_used.first).to eq(original_product2)
      expect(most_used.second).to eq(original_product3)
      expect(most_used.third).to eq(original_product1)
    end
  end
end
