RSpec.describe ItemDecorator do
  let(:item) { create(:item) }
  let(:subitem1) { create(:subitem, item: item) }
  let(:subitem2) { create(:subitem, item: item) }
  let(:subitem3) { create(:subitem, item: item) }
  let(:decorator) { ItemDecorator.decorate(item) }

  ITEM_EXPECTED_KEYS = %w[id name show_order code subitems].freeze

  before { create(:product, items:[item], subitems: [subitem1, subitem2]) }

  it 'has proper keys' do
    decorator_json = decorator.as_json
    expect(decorator_json.keys).to match_array(ITEM_EXPECTED_KEYS)
    expect(decorator_json['subitems'].map{|a| a[:id]}).to match_array([subitem1.id, subitem2.id])
  end
end
