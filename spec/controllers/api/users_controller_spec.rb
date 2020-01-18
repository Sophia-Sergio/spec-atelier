describe Api::UsersController, type: :controller do
  let(:current_user) { create(:user) }
  let(:user2) { create(:user) }
  let!(:session) { create(:session, user: current_user, token: session_token(current_user)) }

  USER_EXPECTED_KEYS = %w[id email jwt first_name last_name birthday office profile_image]

  describe '#update' do
    describe 'when  user logged in' do
      describe 'when user exists and has superadmin role' do
        it 'updates the resource' do
          current_user.add_role :superadmin
          request.headers['Authorization'] = "Bearer #{session.token}"
          put :update, params: { id: user2, user: { first_name: 'test', last_name: 'test_', birthday: '1985-03-19', office: 'spec atelier' } }

          expect(response).to have_http_status(:ok)
          expect(json['user'].keys).to match_array(USER_EXPECTED_KEYS)
          expect(json['user']['first_name']).to eq('test')
          expect(json['user']['last_name']).to eq('test_')
          expect(json['user']['birthday']).to eq('1985-03-19')
          expect(json['user']['office']).to eq('spec atelier')
        end
      end

      describe 'when user exists and does not have superadmin role' do
        describe 'when user is updating itself' do
          it 'updates the resource' do
            current_user.remove_role :superadmin
            request.headers['Authorization'] = "Bearer #{session.token}"
            put :update, params: { id: current_user, user: { first_name: 'test' }}

            expect(response).to have_http_status(:ok)
            expect(json['user']['first_name']).to eq('test')
          end
        end

        describe 'when user is updating another user' do
          it 'cannot updates the resource' do
            current_user.remove_role :superadmin
            request.headers['Authorization'] = "Bearer #{session.token}"
            put :update, params: { id: user2 }

            expect(response).to have_http_status(:forbidden)
          end
        end
      end

      describe 'when user does not exists' do
        it 'returns not_found status' do
          request.headers['Authorization'] = "Bearer #{session.token}"
          put :update, params: { id: '100000' }
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    describe 'without session' do
      before { put :update, params: { id: '100000' }}
      it_behaves_like 'an unauthorized api request'
    end
  end

  describe '#show' do
    describe 'when  user logged in' do
      describe 'when user exists' do
        it 'shows the resource' do
          current_user.add_role :superadmin
          request.headers['Authorization'] = "Bearer #{session.token}"
          get :show, params: { id: user2 }

          expect(response).to have_http_status(:ok)
          expect(json['user'].keys).to match_array(USER_EXPECTED_KEYS)
          expect(json['user']['first_name']).to eq(user2.first_name)
          expect(json['user']['last_name']).to eq(user2.last_name)
        end
      end

      describe 'when user does not exists' do
        it 'returns not_found status' do
          request.headers['Authorization'] = "Bearer #{session.token}"
          get :show, params: { id: '100000' }
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    describe 'without session' do
      before { get :show, params: { id: '100000' }}
      it_behaves_like 'an unauthorized api request'
    end

  end
end
