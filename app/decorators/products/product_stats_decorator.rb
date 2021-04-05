module Products
  class ProductStatsDecorator < ApplicationDecorator
    delegate :id, :name, :updated_at
    new_keys :brand_name, :dwg_downloads, :bim_downloads, :pdf_downloads, :projects_count

    def dwg_downloads
      model.stats_dwg_downloads
    end

    def bim_downloads
      model.stats_bim_downloads
    end

    def pdf_downloads
      model.stats_pdf_downloads
    end

    def projects_count
      model.stats_used_on_spec
    end
  end
end
