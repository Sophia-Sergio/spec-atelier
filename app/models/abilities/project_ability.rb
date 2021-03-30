module Abilities
  class ProjectAbility < Ability
    def user
      can :show, Project, user_id: current_user.id
      can :index, Project, user_id: current_user.id
      can :update, Project, user_id: current_user.id
      can :destroy, Project, user_id: current_user.id
    end
  end
end
