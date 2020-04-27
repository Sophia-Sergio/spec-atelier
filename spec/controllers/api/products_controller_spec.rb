require 'google/cloud/storage'

RSpec.describe Api::ProductsController, type: :controller do
  let(:user)           { create(:user) }
  let(:no_logged_user) { create(:user) }
  let(:session)        { create(:session, user: user, token: session_token(user)) }
  let(:products)       { create_list(:product, 10) }
  let(:product)        { create(:product) }
  let(:brand)          { create(:brand) }
  let(:product_params) { {
                            system_id: product.subitem.id,
                            name: 'new name',
                            long_desc: 'new long desc',
                            brand: brand.name,
                            project_type: '',
                            work_type: '',
                            room_type: [1,2],
                            price: 1000
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

      it 'returns a paginated response' do
        create_list(:product, 21)
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

      it 'returns a resource' do
        image1 = create(:image, owner: product, order: 0)
        image2 = create(:image, owner: product, order: 1)

        get :show, params: { id: product.id }

        expect(json['product']['name']).to eq(product.name)
        expect(json['product']['images'].first['order']).to eq(image1.order)
        expect(json['product']['images'].first['urls']).to eq(image1.all_formats.as_json)
        expect(json['product']['images'].second['urls']).to eq(image2.all_formats.as_json)
      end

      it 'returns a another resource' do
        get :show, params: { id: products.second.id }
        expect(json['product']['name']).to eq(products.second.name)
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
          post :create, params: { product: product_params.except(:brand).merge(brand: 'new brand') }
          expect(response).to have_http_status(:created)
        end
      end

      context 'without all params, without brand' do
        it 'creates a resource' do
          post :create, params: { product: product_params.except(:brand) }
          expect(response).to have_http_status(:unprocessable_entity)
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
      let(:uploaded_file_1) { double("uploaded_file", public_url: "A", content_type: 'image/png') }
      let(:uploaded_file_2) { double("uploaded_file", public_url: "B", content_type: 'image/png') }

      before do
        request.headers['Authorization'] = "Bearer #{session.token}"
        allow_any_instance_of(Google::Cloud::Storage::Bucket).to receive(:upload_file).and_return(uploaded_file_1, uploaded_file_2)
      end

      context 'with all params' do
        it 'creates a resource' do
          image1 = fixture_file_upload('spec/fixtures/images/logo1.png')
          image2 = fixture_file_upload('spec/fixtures/images/logo2.png')
          patch :associate_images, params: { product_id: product.id, product: { images: [image1, image2] } }
          expect(response).to have_http_status(:created)
          expect(product.images.count).to be 2
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
      let(:uploaded_file_1) { double("uploaded_file", public_url: "A", content_type: 'application/pdf') }

      before do
        request.headers['Authorization'] = "Bearer #{session.token}"
        allow_any_instance_of(Google::Cloud::Storage::Bucket).to receive(:upload_file).and_return(uploaded_file_1)
      end

      context 'with all params' do
        it 'attach images to product' do
          pdf = fixture_file_upload('spec/fixtures/documents/example.pdf')
          patch :associate_documents, params: { product_id: product.id, product: { documents: [pdf] } }
          # expect(StorageWorker.perform_async(product, [image1, image2])).to change(StorageWorker.jobs.size).by(1)
          expect(response).to have_http_status(:created)
          expect(product.documents.count).to be 1
        end
      end
    end
  end
end
