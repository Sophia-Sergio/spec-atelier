module ProjectSpec
  class ProjectSpecDecorator < ApplicationDecorator
    new_keys :project, :blocks

    def project
      {
        id: model.project.id,
        name: model.project.name,
        config: model.project.config.as_json(only: :visible_attrs)
      }
    end

    def blocks
      blocks = model.blocks.preload(
        :section,
        :item,
        :product,
        :spec_item,
        :text,
        product: %i[sections subitems brand client files original_product]
      ).order(:order)
      ProjectSpec::BlockDecorator.decorate_collection(blocks)
    end
  end
end
