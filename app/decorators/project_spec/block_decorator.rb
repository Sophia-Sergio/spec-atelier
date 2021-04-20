module ProjectSpec
  class BlockDecorator < ApplicationDecorator
    delegate :section_order, :item_order, :product_order, :id, :order

    new_keys :section,
             :item,
             :type,
             :text,
             :element,
             :product_block_image

    def section
      model.section&.id
    end

    def item
      model.item&.id
    end

    def type
      spec_item.class.to_s
    end

    def text
      ProjectSpec::TextDecorator.decorate(model.text) if model&.text&.present?
    end

    def element
      case type
      when 'Product' then Products::ProductDecorator.decorate(spec_item, context: { block: model } )
      else "ProjectSpec::#{spec_item.class}Decorator".constantize.decorate(spec_item)
      end
    end

    def product_block_image
      model&.product_image&.id if model&.product_image.present?
    end

    private

    def spec_item
      block = model
      model.spec_item.define_singleton_method(:block) { block }
      model.spec_item
    end
  end
end
