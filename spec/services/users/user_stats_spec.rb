describe Users::UserStats, type: :model do
  let(:user) { create(:user, first_name: 'User B', email: 'userB@gmail.com') }
  let(:client) { create(:client) }
  let(:project1) { create(:project, user: user, city: 'City B') }
  let(:project2) { create(:project, user: create(:user, first_name: 'User A', email: 'userA@gmail.com'), city: 'City A') }
  let(:product1) { create(:product, user: user, name: 'Product A', updated_at: DateTime.now, client: client) }
  let(:product2) { create(:product, user: user, name: 'Product B', updated_at: DateTime.now - 1.day, client: client) }
  let(:product3) { create(:product, user: user, name: 'Product C', updated_at: DateTime.now + 1.day, client: client) }
  let(:service)  { Users::UserStats.new(user, params: params) }

  before do
    user.add_role(:client)
    user.clients << client
    product_spec1 = create(:product, created_reason: :added_to_spec, original_product_id: product1.id)
    product_spec2 = create(:product, created_reason: :added_to_spec, original_product_id: product2.id)
    product_spec3 = create(:product, created_reason: :added_to_spec, original_product_id: product3.id)
    product_spec4 = create(:product, created_reason: :added_to_spec, original_product_id: product2.id)
    project1.specification.blocks << create(:spec_block, spec_item: product_spec1, item: product_spec1.items.first)
    project1.specification.blocks << create(:spec_block, spec_item: product_spec2, item: product_spec2.items.first)
    project2.specification.blocks << create(:spec_block, spec_item: product_spec3, item: product_spec3.items.first)
    project2.specification.blocks << create(:spec_block, spec_item: product_spec4, item: product_spec4.items.first)
  end

  describe '#project_stats' do
    let(:json_response) { service.project_stats.as_json['projects'] }

    context 'without product filter' do
      context 'without sort_by and sort_order' do
        let(:params) {{}}

        it 'returns products ordered by name' do
          expect(json_response['total']).to be 2
          expect(json_response['next_page']).to be nil
          expect(json_response['list'].first['name']).to eq project1.name
          expect(json_response['list'].first.keys).to match_array %w[id name project_type city created_at updated_at user_name user_email]
        end
      end
    end

    context 'order by city' do
      context 'sort_order desc' do
        let(:params) {{ sort_by: 'city', sort_order: 'desc' }}

        it 'returns products ordered by name' do
          expect(json_response['list'].first['city']).to eq project1.city
          expect(json_response['list'].second['city']).to eq project2.city
        end
      end

      context 'sort_order asc' do
        let(:params) {{ sort_by: 'city', sort_order: 'asc' }}

        it 'returns products ordered by name' do
          expect(json_response['list'].first['city']).to eq project2.city
          expect(json_response['list'].second['city']).to eq project1.city
        end
      end
    end

    context 'order by user_name' do
      context 'sort_order desc' do
        let(:params) {{ sort_by: 'user_name', sort_order: 'desc' }}

        it 'returns products ordered by name' do
          expect(json_response['list'].first['user_name']).to eq project1.user_name
          expect(json_response['list'].second['user_name']).to eq project2.user_name
        end
      end

      context 'sort_order asc' do
        let(:params) {{ sort_by: 'user_name', sort_order: 'asc' }}

        it 'returns products ordered by name' do
          expect(json_response['list'].first['user_name']).to eq project2.user_name
          expect(json_response['list'].second['user_name']).to eq project1.user_name
        end
      end
    end

    context 'order by user_email' do
      context 'sort_order desc' do
        let(:params) {{ sort_by: 'user_email', sort_order: 'desc' }}

        it 'returns products ordered by name' do
          expect(json_response['list'].first['user_email']).to eq project1.user_email
          expect(json_response['list'].second['user_email']).to eq project2.user_email
        end
      end

      context 'sort_order asc' do
        let(:params) {{ sort_by: 'user_email', sort_order: 'asc' }}

        it 'returns products ordered by name' do
          expect(json_response['list'].first['user_email']).to eq project2.user_email
          expect(json_response['list'].second['user_email']).to eq project1.user_email
        end
      end
    end
  end

  describe '#product_stats' do
    let(:json_response) { service.product_stats.as_json['products'] }

    context 'without project filter' do
      describe 'pagination' do
        before do
          create_list(:product, 10, user: user)
          create(:product, user: user, name: 'Product D')
        end

        context 'page 0 - is the default page' do
          let(:params) {{ limit: 5 }}

          it 'returns only 5 elements' do
            expect(json_response['total']).to be 14
            expect(json_response['list'].count).to be 5
            expect(json_response['next_page']).to be 1
          end
        end

        context 'page 2' do
          let(:params) {{ limit: 5, page: 2 }}

          it 'returns only 5 elements' do
            expect(json_response['total']).to be 14
            expect(json_response['list'].count).to be 4
            expect(json_response['next_page']).to be nil
          end
        end
      end

      context 'without sort_by and sort_order' do
        let(:params) {{}}

        it 'returns products ordered by name' do
          expect(json_response['total']).to be 3
          expect(json_response['next_page']).to be nil
          expect(json_response['list'].first['name']).to eq product1.name
          expect(json_response['list'].first.keys).to match_array %w[id name updated_at brand_name dwg_downloads bim_downloads pdf_downloads projects_count]
        end
      end

      context 'order by updated_at' do
        let(:params) { { sort_by: 'updated_at' }}

        it 'returns products ordered by updated_at asc' do
          expect(json_response['list'].first['id']).to be product2.id
          expect(json_response['list'].second['id']).to be product1.id
          expect(json_response['list'].third['id']).to be product3.id
        end

        context 'sort_order desc' do
          let(:params) { { sort_by: 'updated_at', sort_order: 'desc' }}

          it 'returns products ordered by updated_at desc' do
            expect(json_response['list'].first['id']).to be product3.id
            expect(json_response['list'].second['id']).to be product1.id
            expect(json_response['list'].third['id']).to be product2.id
          end
        end
      end

      context 'order by name' do
        context 'sort_order desc' do
          let(:params) { { sort_by: 'name', sort_order: 'desc' } }

          it 'returns products ordered by name' do
            json_response = service.product_stats.as_json['products']
            expect(json_response['list'].first['name']).to eq product3.name
          end
        end

        context 'sort_order asc' do
          let(:params) { { sort_by: 'name', sort_order: 'asc' } }

          it 'returns products ordered by name' do
            expect(json_response['list'].first['name']).to eq product1.name
          end
        end
      end

      context 'order by brand desc' do
        let(:params) { { sort_by: 'brand_name', sort_order: 'desc' } }

        context 'sort_order desc' do
          it 'returns proper data' do
            expect(json_response['list'].first['brand_name']).to eq product3.brand_name
          end
        end

        context 'sort_order asc' do
          let(:params) { { sort_by: 'brand', sort_order: 'asc' } }
          it 'returns proper data' do
            expect(json_response['list'].first['brand_name']).to eq product1.brand_name
          end
        end
      end

      context 'order by spec (times used on speciication)' do
        let(:params) { { sort_by: 'projects_count', sort_order: 'desc' } }

        context 'sort_order desc' do
          it 'returns proper data' do
            expect(json_response['list'].first['id']).to be product2.id
            expect(json_response['list'].second['id']).to be product1.id
            expect(json_response['list'].third['id']).to be product3.id
          end
        end

        context 'sort_order asc' do
          let(:params) { { sort_by: 'projects_count', sort_order: 'asc' } }
          it 'returns proper data' do
            expect(json_response['list'].first['id']).to be product1.id
            expect(json_response['list'].second['id']).to be product3.id
            expect(json_response['list'].third['id']).to be product2.id
          end
        end
      end
    end

    context 'project filtered' do
      let(:service) { Users::UserStats.new(user, params: params, project: project1) }

      context 'without sort_order and sort_by' do
        context 'without sort_by' do
          let(:params) {{}}

          it 'returns products ordered by name' do
            expect(json_response['total']).to be 2
          end
        end
      end
    end
  end
end
