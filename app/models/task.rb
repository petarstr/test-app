class Task < ApplicationRecord
  validates_presence_of [:title, :priority_id, :project_id]
  validates :done, inclusion: { in: [true, false] }

  belongs_to :project
  belongs_to :priority
  has_many :comments, dependent: :destroy
end
