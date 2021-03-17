describe Api::BrandsController, type: :controller do
  let(:user)           { create(:user) }
  let(:no_logged_user) { create(:user) }
  let(:session)        { create(:session, user: user, token: session_token(user)) }

  before do
    create_list(:brand, 2, :with_client)
    create_list(:brand, 2)
    create_list(:product, 3, user: user)
  end

  describe '#index' do
    context 'without session' do
      it 'returns list of brands' do
        get :index, params: { limit: 10 }

        expect(response).to have_http_status(:ok)
        expect(json['brands']['list'].count).to eq(2)
      end
    end

    context 'with valid session' do
      before { request.headers['Authorization'] = "Bearer #{session.token}" }

      it 'returns list of brands' do
        get :index, params: { limit: 10 }

        expect(response).to have_http_status(:ok)
        expect(json['brands']['list'].count).to eq(5)
      end

      it 'returns list of brands by those who has products by section' do
        section = create(:section)
        item = create(:item, section: section)
        create(:product, items: [item], user: user)
        get :index, params: { limit: 10, section: section.id }

        expect(response).to have_http_status(:ok)
        expect(json['brands']['list'].count).to eq(1)
      end

      it 'returns list of brands by those who has products by item' do
        item = create(:item)
        create(:product, items: [item], user: user)
        get :index, params: { limit: 10, item: [item.id] } # can receive an array

        expect(response).to have_http_status(:ok)
        expect(json['brands']['list'].count).to eq(1)
      end

      it 'returns list of brands that by query search' do
        create(:brand, :with_client, name: 'custom_brand')
        get :index, params: { keyword: 'custom_brand', limit: 10 }

        expect(response).to have_http_status(:ok)
        expect(json['brands']['list'].count).to eq(1)
      end

      it 'returns list of brands with its products by keyword' do
        brand = create(:brand, :with_client, name: 'and')
        brand.products << create_list(:product, 2)
        get :index, params: { keyword: 'and', limit: 10 }

        expect(response).to have_http_status(:ok)
        expect(json['brands']['list'].count).to eq(1)
        expect(json['brands']['list'].first['products_count']).to eq(2)
      end
    end
  end
end
