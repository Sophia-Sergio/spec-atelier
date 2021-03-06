describe User, type: :model do
  let(:user) { create(:user, first_name: nil, last_name: nil) }

  describe '#name' do
    it 'returns nil when first_name and last_name nil' do
      expect(user.name).to be nil
    end
  end

  describe '#client?' do
    context 'when he/she has a client role' do
      before { user.add_role(:client) }

      it 'returns true' do
        expect(user.client?).to be true
      end
    end

    context 'when he/she hasnt a client role' do
      it 'returns true' do
        expect(user.client?).to be false
      end
    end
  end
end
