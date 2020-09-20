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

    it 'returns list of products that belongs to item' do
      request.headers['Authorization'] = "Bearer #{session.token}"
      create_list(:item, 2)
      get :index

      expect(response).to have_http_status(:ok)
      expect(json['items'].count).to eq(2)
    end
  end
end