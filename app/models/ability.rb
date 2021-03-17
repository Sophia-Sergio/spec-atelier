# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(current_user)
    can :index, Brand, id: brand_ids(current_user)

    return unless current_user.present?

    project_permissions(current_user)

    can :show, User
    can :update, Product do |product|
      can :update, Product if product.user == current_user
    end

    can :show, ProjectSpec::Specification do |project_spec|
      project_spec.project.user == current_user
    end

    if current_user.superadmin?
      can :update, User
    elsif current_user.user?
      can :update, User do |user|
        user == current_user
      end
      can :profile_image_upload, User do |user|
        user == current_user
      end
    end
  end

  def brand_ids(current_user)
    (current_user&.products&.pluck(:brand_id) || []) + Brand.with_client.pluck(:id)
  end

  def project_permissions(current_user)
    can :show, Project do |project|
      project.user == current_user
    end

    can :index, Project do |project|
      project.user == current_user
    end

    can :update, Project do |project|
      project.user == current_user
    end

    can :destroy, Project do |project|
      project.user == current_user
    end
  end
end
