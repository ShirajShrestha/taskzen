class Task < ApplicationRecord
  belongs_to :user
  validates :title, presence: true
  validates :priority, inclusion: { in: %w[Low Medium High], message: "%{value} is not a valid priority" }, allow_nil: true
  validates :due_date, presence: true
end
