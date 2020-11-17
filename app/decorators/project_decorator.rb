class ProjectDecorator < ApplicationDecorator
  delegate :id,
            :name,
            :project_type,
            :work_type,
            :country,
            :city,
            :delivery_date,
            :status,
            :project_spec_id,
            :created_at,
            :updated_at,
            :description

  new_keys :project_spec_id


  def project_spec_id
    model.specification.id
  end
end
