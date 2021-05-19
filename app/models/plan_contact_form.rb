class PlanContactForm < ApplicationRecord
  validates :plan_type, :user_name, :items_total, :email, presence: true
  validates :plan_type, inclusion: { in: %w[fijo variable] }
end
