module Abilities
  class ProjectSpecAbility < Ability
    def user
      can [:show, :reorder_blocks], ProjectSpec::Specification do |project_spec|
        project_spec.project.user == current_user
      end
    end
  end
end
