describe Api::ConfigsController, type: :controller do
  let(:user)           { create(:user) }
  let(:no_logged_user) { create(:user) }
  let(:session)        { create(:session, user: user, token: session_token(user)) }
  let(:project_types)  { create_list(:lookup_table, 3, category: 'project_type') }

  describe '#project_data' do
    before do
      create_list(:lookup_table, 2, category: 'work_type')
      create(:lookup_table, category: 'project_type', translation_spa: 'a')
      create_list(
        :lookup_table, 4,
        category: 'room_type',
        related_category: 'project_type',
        related_category_codes: [project_types.first.code, project_types.second.code]
      )
    end

    context 'with valid session' do
      it 'returns list of projects that belongs to user with session initialized ordered by name' do
        request.headers['Authorization'] = "Bearer #{session.token}"
        get :project_data, params: { user_id: user.id }

        %w[work_type project_type room_type].each do |category|
          expect(json[category.pluralize].count).to eq(LookupTable.by_category(category).count)
        end
        expect(json['project_types'].first['name']).to eq('A')
        expect(json['cities'].count).to eq(146)
        expect(json['room_types'].first['project_types'].count).to eq(2)
      end
    end
  end

  describe '#room_types' do

    before do
      create(:lookup_table, category: 'room_type', related_category: 'project_type', related_category_codes: [1, 2])
      create(:lookup_table, category: 'room_type', related_category: 'project_type', related_category_codes: [1, 2, 4])
      create(:lookup_table, category: 'room_type', related_category: 'project_type', related_category_codes: [1, 4])
      request.headers['Authorization'] = "Bearer #{session.token}"

    end

    context 'when project_type ["1", "2"]' do
      it 'returns correct number of room_types' do
        get :room_types, params: { project_type: [1, 2] }

        expect(json['room_types'].count).to be 3
      end

      it 'returns correct number of room_types' do
        get :room_types, params: { project_type: [4] }

        expect(json['room_types'].count).to be 2
      end

      it 'returns correct number of room_types' do
        get :room_types, params: { project_type: [2] }

        expect(json['room_types'].count).to be 2
      end
    end
  end

  describe '#room_types' do

    before do
      room_type1 = create(:lookup_table, category: 'room_type', related_category: 'project_type', related_category_codes: [1, 2])
      create(:lookup_table, category: 'room_type', related_category: 'project_type', related_category_codes: [1, 2, 4])
      create(:lookup_table, category: 'room_type', related_category: 'project_type', related_category_codes: [1, 4])
      create(:product, room_type: [room_type1.code])

      request.headers['Authorization'] = "Bearer #{session.token}"

    end

    context 'when project_type ["1", "2"]' do
      it 'returns correct number of room_types' do
        get :room_types, params: { project_type: [1, 2] }

        expect(json['room_types'].count).to be 3
      end

      it 'returns correct number of room_types with_products' do
        get :room_types, params: { project_type: [1, 2], with_products: true }

        expect(json['room_types'].count).to be 1
      end

      it 'returns correct number of room_types' do
        get :room_types, params: { project_type: [4] }

        expect(json['room_types'].count).to be 2
      end

      it 'returns correct number of room_types' do
        get :room_types, params: { project_type: [2] }

        expect(json['room_types'].count).to be 2
      end
    end
  end
end
