module Attached
  class Document < Attached::File
    scope :with_dwg, -> { by_extension('dwg') }
    scope :with_bim, -> { by_extension('rfa') }
    scope :with_pdf, -> { by_extension('pdf') }

  end
end
