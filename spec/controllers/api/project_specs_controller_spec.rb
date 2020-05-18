describe Api::ProjectSpecsController, type: :controller do
  let(:user)           { create(:user) }
  let(:no_logged_user) { create(:user) }
  let(:session)        { create(:session, user: user, token: session_token(user)) }
  let(:section)        { create(:section) }
  let!(:item)          { create(:item, section: section) }
  let(:project_spec)   { create(:project_spec_specification) }

  describe '#create_text' do
    context 'with valid session' do
      before { request.headers['Authorization'] = "Bearer #{session.token}" }

      it 'created a specification text' do
        post :create_text, params: { user_id: user, project_spec_id: project_spec.id, section_id: section, item_id: item, text: 'fake text' }

        expect(json['text']['text']).to eq('fake text')
      end
    end
  end

end