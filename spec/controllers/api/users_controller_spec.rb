describe Api::UsersController, type: :controller do
  let(:current_user) { create(:user) }
  let(:user2) { create(:user) }
  let!(:session) { create(:session, user: current_user, token: session_token(current_user)) }

  USER_EXPECTED_KEYS = %w[id email jwt first_name last_name profile_image projects_count city company client?]


  describe '#stats' do
    context 'when user is not logged in' do
      before { get :stats, params: { id: current_user } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'when user is logged in' do
      before { request.headers['Authorization'] = "Bearer #{session.token}" }
      context 'when is not a client' do
        before { get :stats, params: { id: current_user } }
        it_behaves_like 'a forbidden api request'
      end

      context 'when is a client' do
        let(:project1) { create(:project, user: current_user, city: 'City B') }
        let(:project2) { create(:project, user: create(:user, first_name: 'User A', email: 'userA@gmail.com'), city: 'City A') }
        let(:product1) { create(:product, user: current_user, name: 'Product A', updated_at: DateTime.now) }
        let(:product2) { create(:product, user: current_user, name: 'Product B', updated_at: DateTime.now - 1.day) }
        let(:product3) { create(:product, user: current_user, name: 'Product C', updated_at: DateTime.now + 1.day) }

        before do
          product_spec1 = create(:product, created_reason: :added_to_spec, original_product_id: product1.id)
          product_spec2 = create(:product, created_reason: :added_to_spec, original_product_id: product2.id)
          product_spec3 = create(:product, created_reason: :added_to_spec, original_product_id: product3.id)
          product_spec4 = create(:product, created_reason: :added_to_spec, original_product_id: product2.id)
          project1.specification.blocks << create(:spec_block, spec_item: product_spec1, item: product1.items.first)
          project1.specification.blocks << create(:spec_block, spec_item: product_spec2, item: product2.items.first)
          project2.specification.blocks << create(:spec_block, spec_item: product_spec3, item: product3.items.first)
          project2.specification.blocks << create(:spec_block, spec_item: product_spec4, item: product2.items.first)
          create(:product, user: current_user, name: 'Product D')
          current_user.add_role(:client)
        end

        context 'when stat param is project_stat' do
          before { get :stats, params: { id: current_user, stat: 'project_stats' } }

          it_behaves_like 'a successfull api request'
          it 'should return the proper data' do
            expect(json['projects']['list'].count).to be 2
          end
        end

        context 'when stat param is project_stat' do
          before { get :stats, params: { id: current_user, stat: 'product_stats' } }

          it_behaves_like 'a successfull api request'
          it 'should return the proper data' do
            expect(json['products']['list'].count).to be 4
          end
        end
      end
    end
  end

  describe '#update' do
    describe 'when  user logged in' do
      describe 'when user exists and has superadmin role' do
        it 'updates the resource' do
          current_user.add_role :superadmin
          request.headers['Authorization'] = "Bearer #{session.token}"
          put :update, params: { id: user2, user: { first_name: 'test', last_name: 'test_'} }

          expect(response).to have_http_status(:ok)
          expect(json['user'].keys).to match_array(USER_EXPECTED_KEYS)
          expect(json['user']['first_name']).to eq('test')
          expect(json['user']['last_name']).to eq('test_')
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

        describe 'when user is not logged in' do
          it 'cannot updates the resource' do
            put :update, params: { id: user2 }

            expect(response).to have_http_status(:unauthorized)
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

  describe '#profile_image_upload' do

    context 'without session' do
      before { patch :profile_image_upload, params: { id: user2.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      let(:uploaded_file_1) { double('uploaded_file', public_url: 'https:://some_url/', content_type: 'image/png', name: 'images/test_file_1.jpg') }
      before do
        request.headers['Authorization'] = "Bearer #{session.token}"
        allow_any_instance_of(GoogleStorage).to receive(:upload).and_return(uploaded_file_1)
      end

      it 'updates successfully' do
        image = fixture_file_upload('spec/fixtures/images/logo1.png')
        patch :profile_image_upload, params: { id: current_user.id, image: image }
        expect(response).to have_http_status(:ok)
        expect(json['user']['profile_image']['name']).to eq(image.original_filename)
      end
    end
  end

  describe '#show' do
    describe 'when  user logged in' do
      before { request.headers['Authorization'] = "Bearer #{session.token}" }

      describe 'when user exists' do
        it 'shows the resource' do
          create_list(:project, 3, user: user2)
          current_user.add_role :superadmin
          get :show, params: { id: user2 }

          expect(response).to have_http_status(:ok)
          expect(json['user'].keys).to match_array(USER_EXPECTED_KEYS)
          expect(json['user']['first_name']).to eq(user2.first_name)
          expect(json['user']['last_name']).to eq(user2.last_name)
          expect(json['user']['projects_count']).to eq(3)
        end
      end

      describe 'when user does not exists' do
        it 'returns not_found status' do
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
