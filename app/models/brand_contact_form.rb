class BrandContactForm < ApplicationRecord
  belongs_to :brand, class_name: 'Company::Brand', foreign_key: 'company_id'
  belongs_to :user
end
