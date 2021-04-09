describe Project, type: :model do
  let(:project) { create(:project) }
  let(:project2) { create(:project) }
  let(:product) { create(:product) }

  describe 'factory built record' do
    before { project.specification.blocks << create(:spec_block, :product) }

    context '#by_product' do
      let(:searched_product) { project.specification.blocks.first.spec_item.original_product }

      context 'when product belongs to a project' do
        it 'should return that project' do
          projects = Project.by_product(searched_product)
          expect(projects.include? project).to be true
        end
      end

      context 'when same product belongs to some projects' do
        before do
          product_used_in_other_project = project.specification.blocks.first.spec_item
          project2.specification.blocks << create(:spec_block, spec_item: product_used_in_other_project, item: product_used_in_other_project.items.first)
        end

        it 'should return those projects' do
          projects = Project.by_product(searched_product)
          expect(projects.include? project).to be true
          expect(projects.include? project2).to be true
        end
      end

      context 'when product belongs to no project' do
        it 'should return that project' do
          projects = Project.by_product(product)
          expect(projects.include? project).to be false
        end
      end
    end
  end
end
