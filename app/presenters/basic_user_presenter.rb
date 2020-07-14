class BasicUserPresenter < Presenter
  will_print :id, :email, :jwt, :first_name, :last_name, :birthday, :office, :profile_image, :projects_count

  def jwt
    subject.session.token rescue 'not logged in'
  end

  def projects_count
    subject.projects.count
  end
end
