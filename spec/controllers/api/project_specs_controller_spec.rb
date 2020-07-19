describe Api::ProjectSpecsController, type: :controller do
  let(:user)           { create(:user) }
  let(:no_logged_user) { create(:user) }
  let(:session)        { create(:session, user: user, token: session_token(user)) }
  let(:section)        { create(:section) }
  let(:item)           { create(:item, section: section) }
  let(:item2)           { create(:item, section: section) }
  let(:project_spec)   { create(:project_spec_specification) }
  let(:spec_block)     { create(:spec_block, project_spec: project_spec) }
  let(:product1)        { create(:product, item: item, section: section) }
  let(:product2)        { create(:product, item: item2, section: section) }
  let(:product3)        { create(:product, item: item, section: section) }

  def create_product_block(product, project_spec )
    create(:spec_block, section: product.section, item: product.item, project_spec: project_spec, spec_item: product )
  end

  def products_ids(blocks)
    blocks.map {|block| block['element']['id'] if block['type'] == 'Product'}.compact
  end

  describe '#create_text' do
    before { create(:section, name: 'Terminación') }

    context 'without session' do
      before { post :create_text, params: { user_id: no_logged_user.id, project_spec_id: project_spec } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      before { request.headers['Authorization'] = "Bearer #{session.token}" }

      it 'created a specification text' do
        post :create_text, params: {
          project_spec_id: project_spec,
          text: 'fake text',
          user_id: user,
          block: spec_block.id,
        }

        expect(json['blocks'].second['text']['text']).to eq('fake text')
      end
    end
  end

  describe '#remove_text' do
    before { create(:section, name: 'Terminación') }

    context 'without session' do
      before { delete :remove_text, params: { user_id: no_logged_user.id, project_spec_id: project_spec } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      before do
        request.headers['Authorization'] = "Bearer #{session.token}"
        @block_product1 = create_product_block(product1, project_spec)
        @block_product2 = create_product_block(product2, project_spec)
        @text = create(:spec_text, block_item: @block_product1 )
        create(:spec_block, spec_item: @text, project_spec: project_spec)
      end

      it 'removes a specification text' do
        expect(project_spec.blocks.unscoped.find_by(spec_item: @text).spec_item).to eq(@text)

        delete :remove_text, params: { user_id: no_logged_user.id, project_spec_id: project_spec, text: @text }

        expect(project_spec.blocks.unscoped.find_by(spec_item: @text)).to eq(nil)
      end
    end
  end

  describe '#create_product' do
    before { create(:section, name: 'Terminación') }

    context 'without session' do
      before { post :create_product, params: { user_id: no_logged_user.id, project_spec_id: project_spec } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      before do
        request.headers['Authorization'] = "Bearer #{session.token}"
        post :create_product, params: {
          project_spec_id: project_spec,
          product: product1,
          user_id: user,
          section: section,
          item: item
        }
      end

      it 'creates a specification product' do
        expect(json['blocks'].third['element']['id']).to eq(product1.id)
      end

      it 'creates a section "Terminación" by default with order 0' do
        expect(project_spec.blocks.find_by(order: 0).spec_item).to eq(Section.find_by(name: 'Terminación'))
      end

      it 'creates a item by default with right order 1' do
        expect(project_spec.blocks.find_by(order: 1).spec_item).to eq(Item.find_by(name: product1.item.name))
      end
    end
  end

  describe '#remove_product' do
    before { create(:section, name: 'Terminación') }

    context 'without session' do
      before { delete :remove_product, params: { project_spec_id: project_spec, block: '1', user_id: no_logged_user.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      before { request.headers['Authorization'] = "Bearer #{session.token}" }

      describe 'remove product when item has 2 products' do
        before do
          @block_product1 = create_product_block(product1, project_spec)
          @block_product2 = create_product_block(product3, project_spec)

          delete :remove_product, params: { project_spec_id: project_spec, user_id: user, block: @block_product1.id }
        end

        it 'returns the listwithout the removed product' do
          expect(products_ids(json['blocks']).include? product1.id).to eq(false)
          expect(project_spec.blocks.find_by(spec_item: product1)).to be(nil)
        end

        it 'reorders the specification items' do
          expect(project_spec.blocks.find_by(spec_item: product3).id).to eq(@block_product2.id)
          expect(project_spec.blocks.find_by(spec_item: product3).order).to be(3)
        end

      end

      describe 'remove product and item when item has only one product' do
        before do
          @block_product1 = create_product_block(product1, project_spec)
          @block_product2 = create_product_block(product2, project_spec)
          @block_product3 = create_product_block(product3, project_spec)
          request.headers['Authorization'] = "Bearer #{session.token}"

          delete :remove_product, params: { project_spec_id: project_spec, user_id: user, block: @block_product2.id }
        end

        it 'returns the list without product removed' do
          expect(products_ids(json['blocks']).include? product2.id).to eq(false)
          expect(project_spec.blocks.find_by(spec_item: product2)).to be(nil)
        end

        it 'removes the item that it belongs' do
          expect(project_spec.blocks.find_by(spec_item: product2.item)).to be(nil)
        end
      end
    end
  end

  describe '#show' do
    before do
      create(:section, name: 'Terminación')

      @block_product1 = create_product_block(product1, project_spec)
      @block_product2 = create_product_block(product2, project_spec)
      @text = create(:spec_text, block_item: @block_product1 )
      @block_text = create(:spec_block, project_spec: project_spec, spec_item: @text )
      @block_product3 = create_product_block(product3, project_spec)
    end

    context 'without session' do
      before { get :show, params: { id: project_spec, user_id: no_logged_user.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      before do
        request.headers['Authorization'] = "Bearer #{session.token}"
        get :show, params: { id: project_spec, user_id: user}
      end

      context 'project spec' do
        it 'has spec_item ordered correctly' do
          expect(json['blocks'].first['order']).to eq(0)
          expect(json['blocks'].first['type']).to eq('Section')

          expect(json['blocks'].second['order']).to eq(1)
          expect(json['blocks'].second['type']).to eq('Item')
          expect(json['blocks'].second['element']['id']).to eq(@block_product1.item.id)

          expect(json['blocks'].third['order']).to eq(2)
          expect(json['blocks'].third['type']).to eq('Product')
          expect(json['blocks'].third['element']['id']).to eq(@block_product1.spec_item.id)
          expect(json['blocks'].third['text']['id']).to eq(@text.id)

          expect(json['blocks'].fourth['order']).to eq(3)
          expect(json['blocks'].fourth['type']).to eq('Product')
          expect(json['blocks'].fourth['element']['id']).to eq(@block_product3.spec_item.id)
          expect(json['blocks'].fourth['text']).to eq(nil)

          expect(json['blocks'].fifth['order']).to eq(4)
          expect(json['blocks'].fifth['type']).to eq('Item')
          expect(json['blocks'].fifth['element']['id']).to eq(@block_product2.item.id)

          expect(json['blocks'][5]['order']).to eq(5)
          expect(json['blocks'][5]['type']).to eq('Product')
          expect(json['blocks'][5]['element']['id']).to eq(@block_product2.spec_item.id)
        end
      end
    end
  end
end
