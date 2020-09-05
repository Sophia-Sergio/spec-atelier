module ProjectSpec
  class SpecificationPresenter < Presenter
    will_print :id, :section, :item, :type, :order, :element, :text, :product_block_image

    def section
      subject.section.id
    end

    def item
      subject.item.id
    end

    def type
      spec_item.class.to_s
    end

    def text
      ProjectSpec::TextPresenter.decorate(subject.text) if subject&.text&.present?
    end

    def element
      decorator = case type
        when 'Product' then "ProductDecorator".constantize.decorate(spec_item)
        else "ProjectSpec::#{spec_item.class}Presenter".constantize.decorate(spec_item)
      end
    end

    def product_block_image
      subject&.product_image&.id if subject&.product_image.present?
    end

    private

    def spec_item
      @spec_item ||= subject.spec_item
    end
  end
end
