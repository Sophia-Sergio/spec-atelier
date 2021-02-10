RSpec.shared_examples 'an unauthorized api request' do
  it 'matches the error response' do
    expect(response).to have_http_status(:unauthorized)
    expect(json.keys).to match_array ['error']
  end
end

RSpec.shared_examples 'a successfull api request' do
  it 'matches the error response' do
    expect(response).to have_http_status(:success)
  end
end
