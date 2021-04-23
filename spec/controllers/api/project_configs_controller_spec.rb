describe Api::ProjectConfigsController, type: :controller do
  let(:user)    { create(:user) }
  let(:session) { create(:session, user: user, token: session_token(user)) }
  let(:project) { create(:project, user: user) }

  describe '#create' do

    context 'wirh session' do
      let(:visible_attrs) {{
        product: {
          all: "true",
          brand: "true",
          long_desc: "true",
          short_desc: "false",
          reference: "true",
        }
      }}

      before { request.headers['Authorization'] = "Bearer #{session.token}" }

      it 'should create a new config' do
        post :create, params: { user_id: user.id, project_id: project.id, project_config: { visible_attrs: visible_attrs} }
        expect(json['project_config']['visible_attrs']['product']).to eq(visible_attrs[:product].as_json)
      end
    end
  end
end
