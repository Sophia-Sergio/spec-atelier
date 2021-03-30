module Abilities
  class BrandAbility < Ability

    def initialize(current_user)
      super(current_user)
      can :index, Brand, id: brand_ids
    end

    private

    def brand_ids
      (current_user&.products&.pluck(:brand_id) || []) + Brand.with_client.pluck(:id)
    end
  end
end
