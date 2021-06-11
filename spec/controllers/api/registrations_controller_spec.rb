describe Api::RegistrationsController, type: :controller do
  USER_EXPECTED_KEYS ||= %w[id email jwt first_name last_name profile_image projects_count city company client_role superadmin_role impersonated]
  describe '#create' do
    before { ActionMailer::Base.deliveries.clear }
    it 'creates a user' do
      get :create, params: { user: { email: 'test@email.com', password: '123456' } }
      expect(User.last.email).to eq('test@email.com')
      expect(json.keys).to match_array(%w[logged_in user])
      expect(json['user'].keys).to match_array(USER_EXPECTED_KEYS)
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end
end
