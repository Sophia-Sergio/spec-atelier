require 'google/cloud/storage'

describe Api::ProductsController, type: :controller do
  let(:user)           { create(:user) }
  let(:no_logged_user) { create(:user) }
  let(:session)        { create(:session, user: user, token: session_token(user)) }
  let(:products)       { create_list(:product, 10) }
  let(:product)        { create(:product) }
  let(:brand_a)        { create(:brand) }
  let(:brand_b)        { create(:brand) }
  let(:section_a)      { create(:section, name: 'Section A') }
  let(:section_b)      { create(:section, name: 'Section B') }
  let(:item_a)         { create(:item, section: section_a) }
  let(:item_b)         { create(:item, section: section_b) }
  let(:subitem)        { create(:subitem) }
  let(:product_params) { {
                            system_id: subitem.id,
                            name: 'new name',
                            long_desc: 'new long desc',
                            brand: brand_a.name,
                            project_type: '',
                            work_type: '',
                            room_type: [1,2],
                            price: 1000,
                            item_id: item_a.id
                          }
                        }

  describe '#index' do
    context 'without session' do
      before { get :index, params: { user_id: no_logged_user.id, id: products.first.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      before do
        request.headers['Authorization'] = "Bearer #{session.token}"
      end

      describe "general pagination" do
        before do
          create_list(:product, 10, item: item_b)
          create_list(:product, 11, item: item_a)
        end

        it 'returns a paginated response' do
          get :index, params: { limit: 10 }

          expect(response).to have_http_status(:ok)
          expect(json['products']['list'].count).to eq(10)
          expect(json['products']['total']).to eq(21)
          expect(json['products']['next_page']).to eq(1)

          get :index, params: { limit: 10, page: 1}

          expect(response).to have_http_status(:ok)
          expect(json['products']['list'].count).to eq(10)
          expect(json['products']['next_page']).to eq(2)

          get :index, params: { limit: 10, page: 2}

          expect(response).to have_http_status(:ok)
          expect(json['products']['list'].count).to eq(1)
          expect(json['products']['next_page']).to eq(nil)
        end

        it 'returns different products by page ordered by section name and product name' do

          get :index, params: { limit: 3, page: 0}
          ids_page_0 = json['products']['list'].map {|p| p['id'] }
          get :index, params: { limit: 3, page: 1}
          ids_page_1 = json['products']['list'].map {|p| p['id'] }
          get :index, params: { limit: 3, page: 2}
          ids_page_2 = json['products']['list'].map {|p| p['id'] }
          get :index, params: { limit: 3, page: 3}
          ids_page_3 = json['products']['list'].map {|p| p['id'] }

          expect(ids_page_0).to eq([11, 12, 13])
          expect(ids_page_1).to eq([14, 15, 16])
          expect(ids_page_2).to eq([17, 18, 19])
          expect(ids_page_3).to eq([20, 21, 1])
        end
      end

      context 'filtered paginated response' do

        before do
          create(:product, name: 'aaab', brand: brand_a)
          create(:product, name: 'baca aaa', project_type: ['1'], brand: brand_b)
          create(:product, name: 'abbb', project_type: ['1'], room_type: ['1'], item: item_b)
          create(:product, name: 'bbba', project_type: ['2'], room_type: ['1'], item: item_a)
          create(:product, name: 'ccca aab', item: item_b)
        end

        it 'returns products by keyword' do
          get :index, params: { limit: 10, page: 0, keyword: 'aaa'}
          expect(json['products']['list'].count).to eq(2)
        end

        it 'returns products by project_type' do
          get :index, params: { limit: 10, page: 0, project_type: [1,2]}
          expect(json['products']['list'].count).to eq(3)
        end

        it 'returns products by room_type default order by section.name' do
          get :index, params: { limit: 10, page: 0, room_type: [1]}
          expect(json['products']['list'].count).to eq(2)
          expect(json['products']['list'].first['name']).to eq('bbba')
          expect(json['products']['list'].first['section']['name']).to eq(section_a.name)
        end

        it 'returns products by room_type ordered by new products (created_at desc)' do
          get :index, params: { limit: 10, page: 0, sort: 'created_at'}
          expect(json['products']['list'].count).to eq(5)
          expect(json['products']['list'].first['name']).to eq('ccca aab')
          expect(json['products']['list'].first['section']['name']).to eq(section_b.name)
        end

        it 'returns products by project_type and room_type' do
          get :index, params: { limit: 10, page: 0,  project_type: [1], room_type: [1]}
          expect(json['products']['list'].count).to eq(1)
        end

        it 'returns products by keyword, project_type and room_type' do
          get :index, params: { limit: 10, page: 0, keyword: 'bbb', project_type: [1], room_type: [1]}
          expect(json['products']['list'].count).to eq(0)
        end

        it 'returns products by keyword and room_type' do
          get :index, params: { limit: 10, page: 0, keyword: 'aaa', project_type: [1] }
          expect(json['products']['list'].count).to eq(1)
        end

        it 'returns products by brand' do
          get :index, params: { limit: 10, page: 0, brand: [brand_a.id, brand_b.id] }
          expect(json['products']['list'].count).to eq(2)
        end

        it 'returns products by section' do
          get :index, params: { limit: 10, page: 0, section: section_b.id }
          expect(json['products']['list'].count).to eq(2)
        end

        it 'returns products by item' do
          get :index, params: { limit: 10, page: 0, item: item_a.id }
          expect(json['products']['list'].count).to eq(1)
        end
      end
    end
  end

  describe '#show' do
    context 'without session' do
      before { get :show, params: { user_id: no_logged_user.id, id: products.first.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      before do
        request.headers['Authorization'] = "Bearer #{session.token}"
      end

      it 'returns a resource with images' do
        image1 = create(:image)
        image2 = create(:image)
        create(:resource_file, owner: product, attached: image1)
        create(:resource_file, owner: product, attached: image2)

        get :show, params: { id: product.id }

        expect(json['product']['name']).to eq(product.name)
        expect(json['product']['images'].first['order']).to eq(0)
        expect(json['product']['images'].second['order']).to eq(1)
        expect(json['product']['images'].first['urls']).to eq(image1.all_formats.as_json)
        expect(json['product']['images'].second['urls']).to eq(image2.all_formats.as_json)
      end

      it 'returns another resource with images' do
        get :show, params: { id: products.second.id }
        expect(json['product']['name']).to eq(products.second.name)
      end

      context 'returns a resource with documents' do
        before do
          @document1 = create(:document, name: 'document.dwg')
          @document2 = create(:document, name: 'document2.pdf')
          @document3 = create(:document, name: 'document1.pdf')
          @document4 = create(:document, name: 'document0.pdf')
          @document5 = create(:document, name: 'document.bim')
          create(:resource_file, owner: product, attached: @document1, order: 0)
          create(:resource_file, owner: product, attached: @document2, order: 2)
          create(:resource_file, owner: product, attached: @document3, order: 1)
          create(:resource_file, owner: product, attached: @document4, order: 3)
          create(:resource_file, owner: product, attached: @document5, order: 4)
          create(:lookup_table, category: 'project_type', code: 1, translation_spa: 'a')
          create(:lookup_table, category: 'project_type', code: 2, translation_spa: 'b')
          create(:lookup_table, category: 'room_type', code: 1, translation_spa: 'a')
          create(:lookup_table, category: 'room_type', code: 2, translation_spa: 'b')
          create(:lookup_table, category: 'work_type', code: 1, translation_spa: 'a')
          create(:lookup_table, category: 'work_type', code: 2, translation_spa: 'b')
          product.update!(project_type: ['1', '2'], room_type: ['1', '2'], work_type: ['1', '2'])
        end

        it 'returns a product with dwg' do

          get :show, params: { id: product.id }

          expect(json['product']['name']).to eq(product.name)
          expect(json['product']['dwg']['name']).to eq(@document1.name)

          expect(json['product']['name']).to eq(product.name)
          expect(json['product']['bim']['name']).to eq(@document5.name)

          expect(json['product']['name']).to eq(product.name)
          expect(json['product']['pdfs'].first['name']).to eq(@document3.name)
          expect(json['product']['pdfs'].second['name']).to eq(@document2.name)

          expect(json['product']['project_type'].first['name']).to eq('a')
          expect(json['product']['project_type'].second['name']).to eq('b')

          expect(json['product']['room_type'].first['name']).to eq('a')
          expect(json['product']['room_type'].second['name']).to eq('b')

          expect(json['product']['work_type'].first['name']).to eq('a')
          expect(json['product']['work_type'].second['name']).to eq('b')
        end
      end
    end
  end

  describe '#update' do
    context 'without session' do
      before { put :update, params: { user_id: no_logged_user.id, id: products.first.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      before do
        request.headers['Authorization'] = "Bearer #{session.token}"
      end

      context 'when current_user did not create the product' do
        it 'returns not authorized' do
          put :update, params: { id: products.first.id }

          expect(response).to have_http_status(:forbidden)
          expect(json['error']).to eq("You are not authorized")
        end
      end

      context 'when current_user did create the product' do
        it 'returns not authorized' do
          product = create(:product, user: user)

          put :update, params: { id: product.id, product: product_params }
          expect(json['product']['name']).to eq(product.reload.name)
        end
      end
    end
  end

  describe '#create' do
    context 'without session' do
      before { post :create, params: { user_id: no_logged_user.id, id: products.first.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      before do
        request.headers['Authorization'] = "Bearer #{session.token}"
      end

      context 'with all params' do
        it 'creates a resource' do
          post :create, params: { product: product_params }
          expect(response).to have_http_status(:created)
        end
      end

      context 'without all params, without existing brand' do
        it 'creates a resource' do
          post :create, params: { product: product_params.except(:brand, :system_id).merge(brand: 'simpson') }
          expect(response).to have_http_status(:created)
        end
      end
    end
  end

  describe '#associate_images' do
    context 'without session' do
      before { patch :associate_images, params: { user_id: no_logged_user.id, product_id: product.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      let(:uploaded_file_1) { double('uploaded_file', public_url: 'A', content_type: 'image/png', name: 'images/test_file_1.jpg') }
      let(:uploaded_file_2) { double('uploaded_file', public_url: 'B', content_type: 'image/png', name: 'images/test_file_2.jpg') }

      before do
        request.headers['Authorization'] = "Bearer #{session.token}"
        allow_any_instance_of(Google::Cloud::Storage::Bucket).to receive(:upload_file).and_return(uploaded_file_1, uploaded_file_2)
      end

      context 'with all params' do
        it 'creates a resource' do
          image1 = fixture_file_upload('spec/fixtures/images/logo1.png')
          image2 = fixture_file_upload('spec/fixtures/images/logo2.png')
          patch :associate_images, params: { product_id: product.id, images: [image1, image2] }
          expect(response).to have_http_status(:created)
          expect(product.images.length).to be 2
        end
      end
    end
  end

  describe '#remove_images' do
    context 'without session' do
      before { delete :remove_images, params: { user_id: no_logged_user.id, product_id: product.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do


      before { request.headers['Authorization'] = "Bearer #{session.token}" }

      context 'with all params' do
        it 'creates a resource' do
          image1 = create(:image)
          image2 = create(:image)
          create(:resource_file, :image, owner: product, attached: image1)
          create(:resource_file, :image, owner: product, attached: image2)

          expect(product.images.length).to be 2

          delete :remove_images, params: { product_id: product.id, images: [image1.id, image2.id] }
          expect(response).to have_http_status(:created)
          expect(product.images.length).to be 0
        end
      end
    end
  end

  describe '#associate_documents' do
    context 'without session' do
      before { patch :associate_documents, params: { user_id: no_logged_user.id, product_id: product.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      let(:uploaded_file_1) { double("uploaded_file", public_url: "A", content_type: 'application/pdf', name: 'pdf_exmaple.pdf') }

      before do
        request.headers['Authorization'] = "Bearer #{session.token}"
        allow_any_instance_of(Google::Cloud::Storage::Bucket).to receive(:upload_file).and_return(uploaded_file_1)
      end

      context 'with all params' do
        it 'attach documents to product' do
          pdf = fixture_file_upload('spec/fixtures/documents/example.pdf')
          patch :associate_documents, params: { product_id: product.id, documents: [pdf] }
          # expect(StorageWorker.perform_async(product, [image1, image2])).to change(StorageWorker.jobs.size).by(1)
          expect(response).to have_http_status(:created)
          expect(product.documents.length).to be 1
        end
      end
    end
  end

  describe '#remove_documents' do
    context 'without session' do
      before { delete :remove_documents, params: { user_id: no_logged_user.id, product_id: product.id } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do


      before { request.headers['Authorization'] = "Bearer #{session.token}" }

      context 'with all params' do
        it 'creates a resource' do
          document1 = create(:document)
          document2 = create(:document)
          create(:resource_file, :document, owner: product, attached: document1)
          create(:resource_file, :document, owner: product, attached: document2)

          expect(product.documents.length).to be 2

          delete :remove_documents, params: { product_id: product.id, documents: [document1.id, document2.id] }
          expect(response).to have_http_status(:created)
          expect(product.documents.length).to be 0
        end
      end
    end
  end

  describe '#form_contact' do
    context 'without session' do
      before { post :contact_form, params:  { product_id: product } }
      it_behaves_like 'an unauthorized api request'
    end

    context 'with valid session' do
      before { request.headers['Authorization'] = "Bearer #{session.token}" }

      it 'returns brand' do
        post :contact_form, params: { product_id: product, product_contact_form: { message: 'message brand', user_phone: '+56 9 99944656' }}

        expect(response).to have_http_status(:created)
        expect(json['message']).to eq('Mensaje enviado')
      end
    end
  end
end
