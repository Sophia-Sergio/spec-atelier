describe Api::ItemsController, type: :controller do
  let(:user)           { create(:user) }
  let(:no_logged_user) { create(:user) }
  let(:session)        { create(:session, user: user, token: session_token(user)) }
  let(:item)           { create(:item) }
  let(:subitem)        { create(:subitem, item: item) }
  let(:item2)          { create(:item) }
  let(:subitem2)       { create(:subitem, item: item2) }

  describe '#subitems' do
    context 'without session' do
      before { get :subitems, params: { user_id: no_logged_user.id, item_id: item2} }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      before do
        request.headers['Authorization'] = "Bearer #{session.token}"
      end

      it 'returns list of products that belongs to item' do
        create_list(:subitem, 2, item: item2)
        get :subitems, params: { user_id: user.id, item_id: item2.id }

        expect(response).to have_http_status(:ok)
        expect(json['systems'].count).to eq(2)
      end
    end
  end

  describe '#index' do
    before do
      request.headers['Authorization'] = "Bearer #{session.token}"
    end

    it 'returns list of items' do
      create_list(:item, 2)
      get :index

      expect(response).to have_http_status(:ok)
      expect(json['items'].count).to eq(2)
    end

    it 'returns list of items with products and filtered by section' do
      section1 = create(:section)
      section2 = create(:section)
      section3 = create(:section)
      item1 = create(:item, section: section1)
      item2 = create(:item, section: section2)
      item3 = create(:item, section: section3)
      create(:product, items: [item1, item3])
      create(:product, items: [item1])
      create(:product, items: [item3])
      get :index, params: { section: [section1.id, section2.id, section3.id], with_products: true }

      expect(response).to have_http_status(:ok)
      expect(json['items'].map {|item| item['id'] }).to match_array([item1.id, item3.id])
    end
  end
end