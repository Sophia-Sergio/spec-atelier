describe User, type: :model do
  let(:user) { create(:user, first_name: nil, last_name: nil) }

  describe '#name' do
    it 'returns nil when first_name and last_name nil' do
      expect(user.name).to be nil
    end
  end
end
