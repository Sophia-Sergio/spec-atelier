module Users
  class UserStats
    attr_reader :user, :product_ability, :project, :product, :params

    def initialize(user, params: {}, project: nil, product: nil)
      @params = params
      @project = project
      @product = product
      @user = user
    end

    def product_stats
      { products: products.paginated_format(Products::ProductStatsDecorator, params) }
    end

    def project_stats
      { projects: projects.paginated_format(Projects::ProjectStatsDecorator, params) }
    end

    private

    def projects
      project_ids = Project.by_product(product || products).select(:id)
      projects = Project.where(id: project_ids)
      sorted_projects(projects)
    end

    def products
      products = if project.present?
        user.products.by_specification(project.specification)
      else
        product_ability = ::Abilities::ProductAbility.new(user)
        Product.accessible_by(product_ability, :client_products)
      end
      sorted_products(products)
    end

    def sorted_products(products)
      sort_by = params[:sort_by]
      sort_order = params[:sort_order]
      case sort_by&.to_sym
      when :brand then products.joins(:brand).order("brands.name #{sort_order || 'asc'}, products.name")
      when :name, :updated_at then products.order("#{sort_by} #{sort_order || 'asc'}, name")
      when :spec then products.joins(:stats).order("product_stats.used_on_spec #{sort_order || 'asc'}, name")
      when :pdf, :dwg, :bim then products.joins(:stats).order("product_stats.#{sort_by}_downloads #{sort_order || 'asc'}, name")
      else products.order(:name)
      end
    end

    def sorted_projects(projects)
      sort_by = params[:sort_by]
      sort_order = params[:sort_order]
      case sort_by&.to_sym
      when :project_type
        sort_order == 'desc' ? projects.sort_by(&:project_type_spa) : projects.sort_by {|p| -p.project_type_spa }
      when :created_at, :updated_at, :city then projects.order("#{sort_by} #{sort_order || 'asc'}, name")
      when :user_name then projects.joins(:user).order("users.first_name #{sort_order || 'asc'}, projects.name")
      when :user_email then projects.joins(:user).order("users.email #{sort_order || 'asc'}, projects.name")
      else projects.order(:name)
      end
    end

  end
end
