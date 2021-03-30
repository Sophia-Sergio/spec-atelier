module Abilities
  class ProductAbility < Ability
    def user
      can :update, Product, user_id: current_user.id
    end
  end
end
