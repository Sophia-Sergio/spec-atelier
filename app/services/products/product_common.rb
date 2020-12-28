module Products
  class ProductCommon
    attr_reader :params, :user, :product

    def initialize(params, user = nil, product = nil)
      @params = params
      @user = user
      @product = product
    end

    private

    def product_params
      params.except(*not_supported_attributes).merge(user_params)
    end

    def user_params
      user.present? ? { user_id: user&.id } : {}
    end

    def not_supported_attributes
      %i[system brand item product section]
    end

    def subitem_belongs_to_known_item?(subitem)
      Item.where(id: params[:item]).joins(:subitems).where(subitems: { id: subitem }).present?
    end
  end
end
