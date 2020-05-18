module ProductsSearch
  extend ActiveSupport::Concern

  def products_filtered
    filter_params.each {|k, v| @list = list&.send("by_#{k}".to_sym, v) unless @list&.count&.zero? }
    sorted_products
  end

  private

  def list
    @list ||= Product.all
  end

  def sorted_products
    if params[:sort].eql? 'created_at'
      list.order(created_at: :desc)
    else
      list.joins(:section).order('sections.name')
    end
  end

  def filter_params
    params.slice(:keyword, :brand, :project_type, :my_specifications, :room_type, :section, :item)
  end
end
