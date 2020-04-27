describe Api::SectionsController, type: :controller do
  let(:user)           { create(:user) }
  let(:no_logged_user) { create(:user) }
  let(:session)        { create(:session, user: user, token: session_token(user)) }
  let(:section)        { create(:section) }


  describe '#index' do
    context 'without session' do
      before { get :index, params: { user_id: no_logged_user.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      it 'returns list of projects that belongs to user with session initialized' do
        request.headers['Authorization'] = "Bearer #{session.token}"
        create_list(:section, 9)
        get :index, params: { user_id: user.id }

        expect(response).to have_http_status(:ok)
        expect(json['sections'].count).to eq(9)
      end
    end
  end


  describe '#items' do
    context 'without session' do
      before { get :items, params: { user_id: no_logged_user.id, section_id: section } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      it 'returns list of projects that belongs to user with session initialized' do
        request.headers['Authorization'] = "Bearer #{session.token}"
        create_list(:item, 5, section: section)
        get :items, params: { user_id: user.id, section_id: section }

        expect(response).to have_http_status(:ok)
        expect(json['items'].count).to eq(5)
      end
    end
  end

  describe '#products' do
    context 'without session' do
      before { get :products, params: { user_id: no_logged_user.id, section_id: section } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do

      let(:section) { create(:section) }
      let(:item) { create(:item, section: section) }

      it 'returns list of projects that belongs to user with session initialized' do
        request.headers['Authorization'] = "Bearer #{session.token}"

        create_list(:product, 11, item: item)
        get :products, params: { section_id: section, limit: 10 }

        expect(response).to have_http_status(:ok)
        expect(json['products']['list'].count).to eq(10)

        get :products, params: { section_id: section, limit: 10, page: 1 }

        expect(response).to have_http_status(:ok)
        expect(json['products']['list'].count).to eq(1)
      end
    end
  end
end