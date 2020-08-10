describe Api::RegistrationsController, type: :controller do
  describe '#create' do
    it 'creates a user' do
      get :create, params: { user: { email: 'test@email.com', password: '123456' } }
      expect(User.last.email).to eq('test@email.com')
      expect(json.keys).to match_array(%w[logged_in user])
      expect(json['user'].keys).to match_array( %w[id email jwt first_name last_name birthday office profile_image projects_count])
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end
end
