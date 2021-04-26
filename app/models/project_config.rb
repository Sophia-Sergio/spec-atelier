class ProjectConfig < ApplicationRecord
  belongs_to :project
  validate :visible_attrs_consistency

  def product_visibility
    visible_attrs["product"]
  end

  private

  def visible_attrs_consistency
    all_true_and_other_false
    long_desc_and_short_desc
  end

  def all_true_and_other_false
    if product_visibility['all'] == true && (
        product_visibility['short_desc'] == false ||
        product_visibility['long_desc'] == false ||
        product_visibility['reference'] == false ||
        product_visibility['brand'] == false
      )
      errors.add(:project_config, 'No puede tener seleccionar todos y además otro atributo en falso')
    end
  end

  def long_desc_and_short_desc
    if product_visibility['short_desc'] == true && product_visibility['long_desc'] == true
      errors.add(:project_config, 'No puede tener descripción larga y corta al mismo tiempo')
    end
  end
end
