# frozen_string_literal: true

module Abilities
  class Ability
    include CanCan::Ability
    attr_reader :current_user

    def initialize(current_user)
      no_logged_user unless current_user.present?
      return unless current_user.present?

      @current_user = current_user

      superadmin if current_user.superadmin?
      client if current_user.client?
      user if current_user.user?
    end

    def superadmin
      can :manage, :all
    end

    # rubocop:disable Layout/EmptyLineBetweenDefs
    def user; end
    def client; end
    def no_logged_user; end
    # rubocop:enable Layout/EmptyLineBetweenDefs
  end
end
