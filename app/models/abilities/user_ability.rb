module Abilities
  class UserAbility < Ability
    def user
      can :show, User, id: current_user.id
      can :update, User, id: current_user.id
      can :profile_image_upload, User, id: current_user.id
      can %i[index impersonate], User if current_user.session&.impersonated
    end

    def client
      can :stats, User
    end

    def superadmin
      can :manage, :all
      can %i[index impersonate], User
    end
  end
end
