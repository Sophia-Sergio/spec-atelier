describe Api::BrandsController, type: :controller do
  let(:user)           { create(:user) }
  let(:no_logged_user) { create(:user) }
  let(:session)        { create(:session, user: user, token: session_token(user)) }
  let(:client)          { create(:client, name: 'zzz and') }

  before do
    create(:client, name: 'brand')
    create(:client, name: 'abc')
    create(:client, name: 'bcd')
    create(:brand, name: 'client')
    create_list(:product, 3, client: client )
  end

  describe '#index' do
    context 'with valid session' do
      before { request.headers['Authorization'] = "Bearer #{session.token}" }

      it 'returns list of brands' do
        get :index, params: { limit: 10 }

        expect(response).to have_http_status(:ok)
        expect(json['brands']['list'].count).to eq(4)
      end

      it 'returns list of brands that by query search' do
        get :index, params: { keyword: 'brand', limit: 10 }

        expect(response).to have_http_status(:ok)
        expect(json['brands']['list'].count).to eq(1)
      end

      it 'returns list of brands with its products by keyword' do

        get :index, params: { keyword: 'and', limit: 10 }

        expect(response).to have_http_status(:ok)
        expect(json['brands']['list'].count).to eq(1)
        expect(json['brands']['list'].first['products_count']).to eq(3)
      end
    end
  end


  describe '#show' do
    context 'without session' do
      before { get :show, params:  { id: client } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      before { request.headers['Authorization'] = "Bearer #{session.token}" }

      it 'returns brand' do
        get :show, params: { id: client }

        KEYS = %w[id name products_count description address country phone web email social_media contact_type product_images]
        expect(response).to have_http_status(:ok)
        expect(json['brand'].keys).to match_array(KEYS)
      end
    end
  end


  describe '#form_contact' do
    context 'without session' do
      before { post :contact_form, params:  { brand_id: client } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      before { request.headers['Authorization'] = "Bearer #{session.token}" }

      it 'returns brand' do
        post :contact_form, params: { brand_id: client, brand_contact_form: { message: 'message brand', user_phone: '+56 9 99944656' }}

        expect(response).to have_http_status(:created)
        expect(json['message']).to eq('Mensaje enviado')
      end
    end
  end
end
