module Abilities
  class ProductAbility < Ability
    def user
      can %i[
        update
        associate_documents
        associate_images
        remove_images
        remove_documents
      ], Product, user_id: current_user.id
      can :contact_form, Product, id: available_products
      common_abilities
    end

    def no_logged_user
      common_abilities
    end

    def common_abilities
      can %i[index show], Product, id: available_products
    end

    private

    def available_products
      products = current_user.present? ? Product.readable_by(current_user) : Product.readable
      products.select(:id).pluck(:id)
    end
  end
end
