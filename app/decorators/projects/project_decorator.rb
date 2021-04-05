module Projects
  class ProjectDecorator < ApplicationDecorator
    delegate :id,
             :name,
             :project_type,
             :work_type,
             :country,
             :city,
             :delivery_date,
             :status,
             :created_at,
             :updated_at

    new_keys :project_spec_id

    def project_spec_id
      model.specification.id
    end

    def size
      model.size || 0
    end

    def description
      model.description || ''
    end
  end
end
