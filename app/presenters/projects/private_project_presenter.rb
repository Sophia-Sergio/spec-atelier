module Projects
  class PrivateProjectPresenter < Presenter
    will_print :id, :name, :project_type, :work_type, :country, :city, :delivery_date, :status, :project_spec_id, :created_at, :updated_at,

    def project_spec_id
      subject.specification.id
    end
  end
end
