module Projects
  class ProjectStatsDecorator < ApplicationDecorator
    delegate :id, :name, :project_type, :city, :created_at, :updated_at
    new_keys :user_name, :user_email

  end
end
