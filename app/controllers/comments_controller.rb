class CommentsController < ApplicationController
  before_action :require_login
  before_action :restrict_access, only: [:destroy]
  before_action :restrict_task_access, only: [:new, :create]

  def new
    @task = Task.find(params[:task_id])
    @comment = Comment.new(task_id: @task.id)
    @comment_files = @comment.comment_files.build(comment_id: @comment_id)
  end

  def create
    @comment = Comment.new(comment_params)
    @comment.task_id = params[:task_id]
    begin
      Comment.transaction do
        @comment.save!
        params.dig('comment_files', 'file')&.each do |f|
          @comment_file = @comment.comment_files.create!(file: f)
        end
        redirect_to task_path(@comment.task)
      end
    rescue StandardError
      redirect_to task_path(@comment.task)
    end
  end

  def destroy
    @comment = Comment.find(params[:id])
    task = @comment.task
    @comment.destroy
    redirect_to task
  end

  private

    def comment_params
      params.require(:comment).permit(:comment)
    end

    def restrict_access
      redirect_to root_path if current_user != Comment.find(params[:id]).task.project.user
    end

    def restrict_task_access
      redirect_to root_path if current_user != Task.find(params[:task_id]).project.user
    end
end
