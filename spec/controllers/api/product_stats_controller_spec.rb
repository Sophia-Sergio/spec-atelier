describe Api::ProductStatsController, type: :controller do
  let(:product) { create(:product, user: user) }
  let(:user)           { create(:user) }
  let(:no_logged_user) { create(:user) }
  let(:session)        { create(:session, user: user, token: session_token(user)) }
  let(:section)        { create(:section) }

  describe '#update_bim_downloads' do
    context 'when it has no access' do

    end

    context 'when it has access' do
      before do
        request.headers['Authorization'] = "Bearer #{session.token}"
      end

      %w[bim_downloads pdf_downloads dwg_downloads].each do |stat|
        context stat do
          it 'sets a +1' do
            patch :update_downloads, params: { product_id: product, stat: stat }
            expect(product.stats.reload.send(stat)).to be 1
          end
        end
      end
    end
  end
end
