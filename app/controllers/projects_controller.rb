class ProjectsController < ApplicationController
  before_action :require_login
  before_action :restrict_access, only: [:edit, :update, :destroy]
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    @projects = Project.all
  end

  def show
    @tasks = @project.tasks
  end

  def new
    @project = Project.new
  end

  def edit
  end

  def create
    @project = Project.new(project_params)
    @project.user_id = current_user.id

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project }
      else
        format.html { render :edit }
      end
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_url
  end

  private

    def set_project
      @project = Project.find(params[:id])
    end

    def project_params
      params.require(:project).permit(:project_name)
    end

    def restrict_access
      redirect_to root_path if current_user != Project.find(params[:id]).user
    end
end
