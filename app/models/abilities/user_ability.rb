module Abilities
  class UserAbility < Ability
    def user
      can :show, User, id: current_user.id
      can :update, User, id: current_user.id
      can :profile_image_upload, User, id: current_user.id
    end

    def client
      can :stats, User
    end
  end
end
