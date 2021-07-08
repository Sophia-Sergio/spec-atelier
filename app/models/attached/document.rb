module Attached
  class Document < Attached::File
    scope :with_dwg, -> { by_extension('dwg') }
    scope :with_bim, -> { by_extension('rfa').or(by_extension('rvt')) }
    scope :with_pdf, -> { by_extension('pdf') }

    EXTENSIONS = %w[dwg rfa rvt pdf].freeze

  end
end
