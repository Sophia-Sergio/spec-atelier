module Users
  class UserUpdater

    attr_reader :params, :user

    def initialize(user, params)
      @user = user
      @params = params
    end

    def call
      user.update(params)
      user.reload
    end

  end
end
