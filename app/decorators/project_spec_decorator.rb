class ProjectSpecDecorator < ApplicationDecorator
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
    ProjectSpec::TextPresenter.decorate(model.text) if model&.text&.present?
  end

  def element
    decorator = case type
      when 'Product' then "ProductDecorator".constantize.decorate(spec_item)
      else "ProjectSpec::#{spec_item.class}Presenter".constantize.decorate(spec_item)
    end
  end

  def product_block_image
    model&.product_image&.id if model&.product_image.present?
  end

  private

  def spec_item
    @spec_item ||= model.spec_item
  end
end
