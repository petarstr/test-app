class CommentFile < ApplicationRecord
  mount_uploader :file, FileUploader
  belongs_to :comment

  before_destroy :remember_id
  after_destroy :remove_id_directory

  protected

  def remember_id
    @id = id
  end

  def remove_id_directory
    FileUtils.remove_dir("#{Rails.root}/public/uploads/comment_file/file/#{@id}")
  end
end
