module ProjectSpec
  class ItemPresenter < Presenter
    will_print :id, :name

    def name
      "#{subject.block.section_order}.#{subject.block.item_order}. #{subject.name}"
    end
  end
end