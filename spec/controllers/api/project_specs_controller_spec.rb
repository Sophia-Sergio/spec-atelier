describe Api::ProjectSpecsController, type: :controller do
  let(:user)           { create(:user) }
  let(:no_logged_user) { create(:user) }
  let(:session)        { create(:session, user: user, token: session_token(user)) }
  let(:section)        { create(:section) }
  let(:item)           { create(:item, section: section) }
  let(:project_spec)   { create(:project_spec_specification) }
  let(:spec_block)     { create(:spec_block, project_spec: project_spec) }
  let(:product1)        { create(:product, item: item, section: section) }
  let(:product2)        { create(:product, item: item, section: section) }

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

        expect(json['text']['text']).to eq('fake text')
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
        expect(json['product']['id']).to eq(product1.id)
      end

      it 'creates a section "Terminación" by default with order 0' do
        expect(project_spec.blocks.find_by(order: 0).spec_item).to eq(Section.find_by(name: 'Terminación'))
      end

      it 'creates a item by default with right order 1' do
        expect(project_spec.blocks.find_by(order: 1).spec_item).to eq(Item.find_by(name: product1.item.name))
      end
    end

    describe '#show' do
      before do
        request.headers['Authorization'] = "Bearer #{session.token}"

        create(:spec_block,section: product1.section, item: product1.item, project_spec: project_spec, spec_item: product1 )
        block_product1 = create(:spec_block, section: product2.section, item: product2.item, project_spec: project_spec, spec_item: product2 )
        text = create(:spec_text, block_item: block_product1 )
        block_text = create(:spec_block, project_spec: project_spec, spec_item: text )

        get :show, params: { id: project_spec, user_id: user}
      end

      context 'project spec' do
        it 'has spec_item ordered correctly' do
          expect(json['blocks'].first['order']).to eq(0)
          expect(json['blocks'].second['order']).to eq(1)
          expect(json['blocks'].third['order']).to eq(2)
          expect(json['blocks'].fourth['order']).to eq(3)
        end
      end
    end
  end
end
