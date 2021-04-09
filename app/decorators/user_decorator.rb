class UserDecorator < ApplicationDecorator
  delegate :id, :email, :first_name, :last_name, :company, :city
  new_keys :jwt, :projects_count, :profile_image, :client_role

  def jwt
    model.session.token rescue 'not logged in'
  end

  def client_role
    model.client?
  end

  def projects_count
    model.projects.count
  end

  def profile_image
    return unless model.profile_image.present?

    image = model.profile_image
    { id: image.id, name: image.name, urls: image.all_formats }
  end

end
