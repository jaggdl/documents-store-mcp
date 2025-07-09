class ProjectsController < ApplicationController
  before_action :set_project, only: [ :show, :edit, :update, :destroy ]

  def index
    @projects = Project.includes(:documents).all
  end

  def show
    @documents = @project.documents
    add_breadcrumb("Projects", projects_path)
    add_breadcrumb(@project.name)
  end

  def new
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to @project, notice: "Project was successfully created."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: "Project was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @project.destroy
    redirect_to projects_url, notice: "Project was successfully deleted."
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end
end
