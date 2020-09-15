module ProjectSpec
  class SectionPresenter < Presenter
    will_print :id, :name

    def name
      "#{subject.block.section_order}. #{subject.name}"
    end
  end
end