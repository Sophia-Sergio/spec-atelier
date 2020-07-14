describe Api::ConfigsController, type: :controller do
  let(:user)           { create(:user) }
  let(:no_logged_user) { create(:user) }
  let(:session)        { create(:session, user: user, token: session_token(user)) }

  describe '#project_data' do
    before do
      create_list(:lookup_table, 2, category: 'work_type')
      create_list(:lookup_table, 3, category: 'project_type')
      create(:lookup_table, category: 'project_type', translation_spa: 'a')
      create_list(:lookup_table, 4, category: 'room_type')
    end

    context 'without session' do
      before { get :project_data, params: { user_id: no_logged_user.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      it 'returns list of projects that belongs to user with session initialized ordered by name' do
        request.headers['Authorization'] = "Bearer #{session.token}"
        get :project_data, params: { user_id: user.id }

        %w[work_type project_type room_type].each do |category|
          expect(json[category.pluralize].count).to eq(LookupTable.by_category(category).count)
        end
        expect(json['project_types'].first['name']).to eq('a')
        expect(json['cities'].count).to eq(146)
      end
    end
  end
end
