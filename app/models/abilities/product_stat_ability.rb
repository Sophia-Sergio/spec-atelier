module Abilities
  class ProductStatAbility < Ability
    def user
      can :update_downloads, ProductStat, product_id: products_available
    end

    def products_available
      ability = Abilities::ProductAbility.new(current_user)
      Product.accessible_by(ability).by_client(current_user.clients).pluck(:id)
    end
  end
end
