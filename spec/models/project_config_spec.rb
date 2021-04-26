describe ProjectConfig, type: :model do
  let(:project) { create(:project) }
  let(:config) { project.config }

  context 'validate' do
    context 'visible_attrs_consistency' do
      let(:params) { {
        'product' => {
          'all' => false,
          'short_desc' => false,
          'long_desc' => true,
          'reference' => true,
          'brand' => true
        }
      }}

      context 'product all = true and another with false' do
        it 'should raise ActiveRecord::RecordInvalid' do
          visible_attrs = params.deep_merge('product' => { 'all' => true })
          error_message =  'Validation failed: Project config No puede tener seleccionar todos y además otro atributo en falso'
          expect { config.update!(visible_attrs: visible_attrs) }.to raise_error(ActiveRecord::RecordInvalid, error_message)
        end
      end

      context 'product long_desc = true & short_desc = true' do
        it 'should raise ActiveRecord::RecordInvalid' do
          visible_attrs = params.deep_merge('product' => { 'short_desc' => true })
          error_message =  'Validation failed: Project config No puede tener descripción larga y corta al mismo tiempo'
          expect { config.update!(visible_attrs: visible_attrs) }.to raise_error(ActiveRecord::RecordInvalid, error_message)
        end
      end

      context 'with ideal attributes' do
        it 'should be saved' do
          visible_attrs = params.deep_merge('product' => { 'brand' => false })
          config.update!(visible_attrs: visible_attrs)
          expect(config.visible_attrs).to eq(visible_attrs)
        end
      end
    end
  end

end
