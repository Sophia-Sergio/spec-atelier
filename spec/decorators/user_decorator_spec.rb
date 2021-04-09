RSpec.describe UserDecorator do
  let(:user) { create(:user) }
  let(:decorator) { UserDecorator.decorate(user) }

  USER_EXPECTED_KEYS = %w[id email jwt first_name last_name profile_image projects_count city company role_client].freeze

  it 'has proper keys' do
    decorator_json = decorator.as_json
    expect(decorator_json.keys).to match_array(USER_EXPECTED_KEYS)
  end
end
