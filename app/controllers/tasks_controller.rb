class TasksController < ApplicationController
  before_action :require_login
  before_action :restrict_access, only: [:edit, :update, :destroy]
  before_action :restrict_project_access, only: [:new, :create]
  before_action :set_task, only: [:show, :edit, :update, :destroy]

  def index
    @project = Project.find(params[:project_id])
    @tasks = @project.tasks
  end

  def show
  end

  def new
    @project = Project.find(params[:project_id])
    @task = Task.new
  end

  def edit
    @priorities = Priority.all
  end

  def create
    @project = Project.find(params[:project_id])
    @task = Task.new(task_params)
    @task.project_id = params[:project_id]
    respond_to do |format|
      if @task.save
        format.html { redirect_to project_path(@project) }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @task }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @task.destroy
    redirect_to project_path(@task.project)
  end

  private

    def set_task
      @task = Task.find(params[:id])
    end

    def task_params
      params.require(:task).permit(:title, :description, :deadline, :done, :priority_id)
    end

    def restrict_access
      redirect_to root_path if current_user != Task.find(params[:id]).project.user
    end

    def restrict_project_access
      redirect_to root_path if current_user != Project.find(params[:project_id]).user
    end
end
