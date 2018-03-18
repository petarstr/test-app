class Project < ApplicationRecord
  validates_presence_of :project_name

  belongs_to :user
  has_many :tasks, dependent: :destroy
end
