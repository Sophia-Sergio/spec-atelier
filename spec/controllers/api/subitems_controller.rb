describe Api::SubitemsController, type: :controller do
  let(:user)           { create(:user) }
  let(:no_logged_user) { create(:user) }
  let(:session)        { create(:session, user: user, token: session_token(user)) }

  describe '#index' do
    before do
      request.headers['Authorization'] = "Bearer #{session.token}"
    end

    it 'returns list of subitems' do
      create_list(:subitem, 2)
      get :index

      expect(response).to have_http_status(:ok)
      expect(json['subitems'].count).to eq(2)
    end

    it 'returns list of subitems with products and filtered by items' do
      item1 = create(:item)
      item2 = create(:item)
      item3 = create(:item)
      subitem1 = create(:subitem, item: item1)
      subitem2 = create(:subitem, item: item2)
      subitem3 = create(:subitem, item: item3)
      subitem4 = create(:subitem, item: item1)

      get :index, params: {item_id: [item1.id, item2.id] }

      expect(response).to have_http_status(:ok)
      expect(json['subitems'].count).to eq(3)
      expect(json['subitems'].map {|subitem| subitem['id'] }).to match_array([subitem1.id, subitem2.id, subitem4.id])
    end
  end
end
