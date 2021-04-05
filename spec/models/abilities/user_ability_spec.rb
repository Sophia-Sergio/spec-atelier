describe Abilities::UserAbility, type: :model do
  describe 'user' do
    let(:user) { create(:user) }

    context '#stats' do
      context 'when is a client' do
        before { user.add_role(:client) }

        it 'ability should return true' do
          ability = Abilities::UserAbility.new(user)
          expect(ability.can?(:stats, User)).to be true
        end
      end

      context 'when is not a client' do
        it 'ability should return true' do
          ability = Abilities::UserAbility.new(user)
          expect(ability.can?(:stats, User)).to be false
        end
      end
    end
  end
end
