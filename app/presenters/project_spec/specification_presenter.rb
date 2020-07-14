module ProjectSpec
  class SpecificationPresenter < Presenter
    will_print :id, :section, :item, :type, :order, :element

    def section
      subject.section.id
    end

    def item
      subject.item.id
    end

    def type
      spec_item.class.to_s
    end

    def element
      decorator = case type
        when 'Product' then "Products::#{spec_item.class}Presenter".constantize.decorate(spec_item)
        else "ProjectSpec::#{spec_item.class}Presenter".constantize.decorate(spec_item)
      end
      decorator.as_json.merge(text)
    end

    private

    def text
      subject.text.present? ? { text: ProjectSpec::TextPresenter.decorate(subject.text) } : {}
    end

    def spec_item
      @spec_item ||= subject.spec_item
    end
  end
end
