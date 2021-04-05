describe ProjectSpec::Block, type: :model do
  let(:user) { create(:user) }
  let(:project) { create(:project, user: user) }
  let(:project_spec) { create(:project_spec_specification, project: project) }

  let(:section1) { create(:section, show_order: 1) }
  let(:section2) { create(:section, show_order: 2) }
  let(:item1) { create(:item, section: section1) }
  let(:item2) { create(:item, section: section2) }

  let(:product1) { create(:product, spec_item: item1) }
  let(:product2) { create(:product, spec_item: item2) }

  describe 'Orders the blocks by the sections show_order' do
    it 'attaches a file' do
      create(:spec_block, section: section2, item: item2, project_spec: project_spec, spec_item: product2 )
      create(:spec_block, section: section1, item: item1, project_spec: project_spec, spec_item: product1 )

      block_sections = project_spec.reload.blocks.order(:section_order).select {|block| block.spec_item_type == 'Section'}
      expect(block_sections.first.spec_item).to eq(section1)
    end
  end
end
