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

  describe '#room_types_by_project_type' do

    before do
      create(:lookup_table, category: 'room_type', related_category: 'project_type', related_category_codes: [1, 2])
      create(:lookup_table, category: 'room_type', related_category: 'project_type', related_category_codes: [1, 2, 4])
      create(:lookup_table, category: 'room_type', related_category: 'project_type', related_category_codes: [1, 4])
      request.headers['Authorization'] = "Bearer #{session.token}"

    end

    context 'when project_type ["1", "2"]' do
      it 'returns correct number of room_types' do
        get :room_types_by_project_type, params: { project_types: [1, 2] }

        expect(json['room_types'].count).to be 3
      end

      it 'returns correct number of room_types' do
        get :room_types_by_project_type, params: { project_types: [4] }

        expect(json['room_types'].count).to be 2
      end

      it 'returns correct number of room_types' do
        get :room_types_by_project_type, params: { project_types: [2] }

        expect(json['room_types'].count).to be 2
      end
    end
  end
end
