# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(current_user)
    can :show, User

    can :update, Product do |product|
      can :update, Product if product.user ==  current_user
    end

    if current_user.superadmin?
      can :update, User
    elsif current_user.user?
      can :update, User do |user|
        user == current_user
      end
    end
  end
end
