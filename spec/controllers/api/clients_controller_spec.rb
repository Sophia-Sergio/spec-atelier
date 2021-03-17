describe Api::ClientsController, type: :controller do
  let(:user)           { create(:user) }
  let(:no_logged_user) { create(:user) }
  let(:session)        { create(:session, user: user, token: session_token(user)) }
  let(:client)          { create(:client, name: 'zzz and') }

  before do
    create(:client, name: 'cliente')
    create(:client, name: 'abc')
    create(:client, name: 'bcd')
    brand = create(:brand, name: 'brand', client: client)
    create_list(:product, 3, client: client)
  end

  describe '#index' do
    context 'with valid session' do
      before { request.headers['Authorization'] = "Bearer #{session.token}" }

      it 'returns list of clients' do
        get :index, params: { limit: 10 }

        expect(response).to have_http_status(:ok)
        expect(json['clients']['list'].count).to eq(4)
      end

      it 'returns list of clients by those who has products by section' do
        section = create(:section)
        item = create(:item, section: section)
        client.products << create(:product, items: [item])
        get :index, params: { limit: 10, section: section.id }

        expect(response).to have_http_status(:ok)
        expect(json['clients']['list'].count).to eq(1)
      end

      it 'returns list of clients by those who has products by item' do
        item = create(:item)
        client.products << create(:product, items: [item])
        get :index, params: { limit: 10, item: [item.id] } # can receive an array

        expect(response).to have_http_status(:ok)
        expect(json['clients']['list'].count).to eq(1)
      end

      it 'returns list of clients that by query search' do
        get :index, params: { keyword: 'cliente', limit: 10 }

        expect(response).to have_http_status(:ok)
        expect(json['clients']['list'].count).to eq(1)
      end

      it 'returns list of clients with its products by keyword' do
        get :index, params: { keyword: 'and', limit: 10 }

        expect(response).to have_http_status(:ok)
        expect(json['clients']['list'].count).to eq(1)
        expect(json['clients']['list'].first['products_count']).to eq(3)
      end
    end
  end


  describe '#show' do
    context 'with valid session' do
      before { request.headers['Authorization'] = "Bearer #{session.token}" }

      it 'returns client' do
        get :show, params: { id: client }

        KEYS = %w[id name products_count description address country phone web email logo social_media contact_type product_images]
        expect(response).to have_http_status(:ok)
        expect(json['client'].keys).to match_array(KEYS)
      end
    end
  end


  describe '#form_contact' do
    context 'without session' do
      before { post :contact_form, params:  { client_id: client } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      before { request.headers['Authorization'] = "Bearer #{session.token}" }

      it 'returns client' do
        post :contact_form, params: { client_id: client, client_contact_form: { message: 'message client', user_phone: '+56 9 99944656' }}

        expect(response).to have_http_status(:created)
        expect(json['message']).to eq('Mensaje enviado')
      end
    end
  end
end
