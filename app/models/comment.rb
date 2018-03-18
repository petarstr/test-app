class Comment < ApplicationRecord
  validates_presence_of :comment

  has_many :comment_files, inverse_of: :comment, dependent: :destroy
  accepts_nested_attributes_for :comment_files, allow_destroy: true
  belongs_to :task
end
