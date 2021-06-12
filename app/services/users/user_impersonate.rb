module Users
  class UserImpersonate
    extend CallableCommand
    include SessionManipulator

    attr_reader :user

    def initialize(user)
      @user = user
    end

    def call
      start_session(user, true)
      user
    end
  end
end
