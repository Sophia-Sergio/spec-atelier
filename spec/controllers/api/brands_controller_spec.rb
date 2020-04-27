describe Api::BrandsController, type: :controller do
  let(:user)           { create(:user) }
  let(:no_logged_user) { create(:user) }
  let(:session)        { create(:session, user: user, token: session_token(user)) }

  before do
    create(:brand, name: 'brand')
    create(:brand, name: 'abc')
    create(:brand, name: 'bcd')
    create(:brand, name: 'zzz and')
  end

  describe '#index' do
    context 'without session' do
      before { get :index, params: { user_id: no_logged_user.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      before do
        request.headers['Authorization'] = "Bearer #{session.token}"
      end

      it 'returns list of brands that by query search' do
        get :index

        expect(response).to have_http_status(:ok)
        expect(json['brands'].count).to eq(4)
      end
    end
  end

  describe '#search' do
    context 'without session' do
      before { get :search, params: { user_id: no_logged_user.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      before do
        request.headers['Authorization'] = "Bearer #{session.token}"
      end

      it 'returns list of brands that by query search' do

        get :search, params: { query: 'brand' }

        expect(response).to have_http_status(:ok)
        expect(json['brands'].count).to eq(1)

        get :search, params: { query: 'and' }

        expect(response).to have_http_status(:ok)
        expect(json['brands'].count).to eq(2)
      end
    end
  end
end
