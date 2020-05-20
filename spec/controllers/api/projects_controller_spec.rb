describe Api::ProjectsController, type: :controller do
  before do
    create(:lookup_table, category: 'project_type', code: 1, value: 'new_building')
    create(:lookup_table, category: 'project_type', code: 1, value: 'real_state')
  end

  let(:user)           { create(:user) }
  let(:no_logged_user) { create(:user) }
  let(:session)        { create(:session, user: user, token: session_token(user)) }
  let!(:project1)      { create(:project, name: 'zbc abd aci', user: user) }
  let!(:project2)      { create(:project, name: 'aca abc abi', user: user) }
  let!(:project3)      { create(:project, name: 'bca abd abi', user: user) }

  describe '#index' do
    context 'without session' do
      before { get :index, params: { user_id: no_logged_user.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      it 'returns list of projects that belongs to user with session initialized' do
        request.headers['Authorization'] = "Bearer #{session.token}"
        get :index, params: { user_id: user.id }

        expect(json['projects'].count).to eq(3)
        expect(json['projects'].first['name']).to eq(project3.name)
        expect(json['projects'].second['name']).to eq(project2.name)
        expect(json['projects'].third['name']).to eq(project1.name)
        expect(json['projects'].first.keys).to match_array(%w[id name project_type work_type country city delivery_date status created_at updated_at])
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

  describe '#search' do
    context 'without session' do
      before { get :search, params: { user_id: no_logged_user.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      it 'searchs for projects containing matching with searched keywords' do
        request.headers['Authorization'] = "Bearer #{session.token}"
        get :search, params: {  user_id: user.id, search_keywords: 'c ab' }

        expect(json['projects'].count).to eq(2)
      end
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
        patch :update, params: { user_id: user.id, id: project1.id, project: { name: 'new name', project_type: "new_building" } }

        expect(project1.reload.name).to eq('new name')
        expect(project1.reload.new_building?).to eq(true)
      end
    end
  end

  describe '#ordered' do
    context 'with valid session' do
      before { request.headers['Authorization'] = "Bearer #{session.token}" }

      context 'by created_at asc' do
        it 'return a list of projects ordered by parameter' do
          get :ordered, params: { user_id: user.id, ordered_by: 'created_at_asc' }

          expect(json['projects'].first['name']).to eq(project1.name)
        end
      end

      context 'by created_at desc' do
        it 'return a list of projects ordered by parameter' do
          get :ordered, params: { user_id: user.id, ordered_by: 'created_at_desc' }

          expect(json['projects'].first['name']).to eq(project3.name)
        end
      end

      context 'by updated_at asc' do
        it 'return a list of projects ordered by parameter' do
          get :ordered, params: { user_id: user.id, ordered_by: 'updated_at_asc' }

          expect(json['projects'].first['name']).to eq(project1.name)
        end
      end

      context 'by updated_at desc' do
        it 'return a list of projects ordered by parameter' do
          project2.update(name: 'another_name')
          get :ordered, params: { user_id: user.id, ordered_by: 'updated_at_desc' }

          expect(json['projects'].first['name']).to eq(project2.name)
        end
      end

      context 'by name' do
        it 'return a list of projects ordered by parameter' do
          get :ordered, params: { user_id: user.id, ordered_by: 'name_asc' }

          expect(json['projects'].first['name']).to eq(project2.name)
        end
      end
    end
  end
end
