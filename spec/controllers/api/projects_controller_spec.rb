describe Api::ProjectsController, type: :controller do
  before do
    create(:lookup_table, category: 'project_type', code: 1, value: 'new_building')
    create(:lookup_table, category: 'project_type', code: 2, value: 'real_state')
  end

  let(:user)           { create(:user) }
  let(:user2)           { create(:user) }
  let(:no_logged_user) { create(:user) }
  let(:session)        { create(:session, user: user, token: session_token(user)) }
  let!(:project1)      { create(:project, name: 'zbc abd aci', user: user) }
  let!(:project2)      { create(:project, name: 'aca abc abi', user: user) }
  let!(:project3)      { create(:project, name: 'bca abd abi', user: user) }
  let!(:project4)      { create(:project, name: 'bca abd abi', user: user2) }

  describe '#index' do
    context 'without session' do
      before { get :index, params: { user_id: no_logged_user.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session, paginated response' do
      before do
        request.headers['Authorization'] = "Bearer #{session.token}"
      end
      it 'returns list of projects that belongs to user with session initialized' do

        get :index, params: { user_id: user.id, limit: 10 }

        expect(json['projects']['list'].count).to eq(3)
        expect(json['projects']['list'].first['name']).to eq(project3.name)
        expect(json['projects']['list'].second['name']).to eq(project2.name)
        expect(json['projects']['list'].third['name']).to eq(project1.name)
        expect(json['projects']['list'].first.keys).to match_array(%w[id name project_type work_type country city delivery_date status created_at updated_at])
      end
      context 'by created_at asc' do
        it 'return a list of projects ordered by parameter' do
          get :index, params: { user_id: user.id, sort: 'created_at_asc', limit: 10 }
          expect(json['projects']['list'].first['name']).to eq(project1.name)
        end
      end

      context 'by created_at desc' do
        it 'return a list of projects ordered by parameter' do
          get :index, params: { user_id: user.id, sort: 'created_at_desc', limit: 10 }
          expect(json['projects']['list'].first['name']).to eq(project3.name)
        end
      end

      context 'by updated_at asc' do
        it 'return a list of projects ordered by parameter' do
          get :index, params: { user_id: user.id, sort: 'updated_at_asc', limit: 10 }
          expect(json['projects']['list'].first['name']).to eq(project1.name)
        end
      end

      context 'by updated_at desc' do
        it 'return a list of projects ordered by parameter' do
          project2.update(name: 'another_name')
          get :index, params: { user_id: user.id, sort: 'updated_at_desc', limit: 10 }
          expect(json['projects']['list'].first['name']).to eq(project2.name)
        end
      end

      context 'by name asc' do
        it 'return a list of projects ordered by parameter' do
          get :index, params: { user_id: user.id, sort: 'name_asc', limit: 10 }
          expect(json['projects']['list'].first['name']).to eq(project2.name)
        end
      end

      context 'by keyword' do
        it 'searchs for projects containing matching with searched keywords' do
          get :index, params: {  user_id: user.id, keyword: 'abi' }
          expect(json['projects'].count).to eq(2)
        end
      end
    end
  end

  describe '#show' do
    context 'without session' do
      before { get :show, params: { user_id: no_logged_user.id, id: project1.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      it 'returns a resource' do
        request.headers['Authorization'] = "Bearer #{session.token}"
        get :show, params: { user_id: user.id, id: project1.id }

        expect(json['project']['name']).to eq(project1.name)
      end
    end
  end

  describe '#create' do
    context 'without session' do
      before { post :create, params: { user_id: no_logged_user.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      it 'creates a project' do
        request.headers['Authorization'] = "Bearer #{session.token}"
        post :create, params: { user_id: user.id, project: { name: 'fake project', project_type: 'real_state', work_type: 'new_building'  } }

        expect(Project.last.name).to eq('fake project')
        expect(Project.last.user.id).to eq(user.id)
        expect(response).to have_http_status(:created)
        expect(json['project']['name']).to eq('fake project')
      end
    end
  end

  describe '#delete' do
    it 'soft deletes a project' do
      request.headers['Authorization'] = "Bearer #{session.token}"
      delete :destroy, params: { user_id: user.id, id: project1.id }

      expect(project1.soft_deleted).to eq(false)
      expect(project1.reload.soft_deleted).to eq(true)
    end
  end

  describe '#update' do
    context 'without session' do
      before { patch :update, params: { user_id: no_logged_user.id, id: project1.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      it 'updates a project' do
        request.headers['Authorization'] = "Bearer #{session.token}"
        patch :update, params: { user_id: user.id, id: project1.id, project: { name: 'new name', project_type: 'real_state' } }

        expect(project1.reload.name).to eq('new name')
        # expect(project1.reload.new_building?).to eq(true)
      end
    end
  end
end
