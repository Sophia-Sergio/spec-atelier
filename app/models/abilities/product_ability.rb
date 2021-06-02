module Abilities
  class ProductAbility < Ability
    def user
      can %i[
        destroy
        update
        associate_documents
        associate_images
        remove_images
        remove_documents
      ], Product, user_id: current_user.id
      can :contact_form, Product, id: available_products
      can :show, Product, user_id: current_user.id
      common_abilities
    end

    def client
      can :client_products, Product, id: client_products
    end

    def no_logged_user
      common_abilities
    end

    def common_abilities
      can :index, Product, id: available_products
      can :show, Product, id: available_products
    end

    private

    def client_products
      Product.original.by_user(current_user).pluck(:id) + Product.by_client(current_user.clients).pluck(:id)
    end

    def available_products
      products = current_user.present? ? Product.readable_by(current_user) : Product.readable
      products.select(:id).pluck(:id)
    end
  end
end
