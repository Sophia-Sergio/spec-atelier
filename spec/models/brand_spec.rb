describe Brand, type: :model do

  context 'scopes' do
    context ':with_client' do
      before do
        create_list(:brand, 3, :with_client)
        create_list(:brand, 3)
      end

      it 'fetchs only brands with clients' do
        expect(Brand.with_client.count).to be(3)
      end
    end
  end
end
