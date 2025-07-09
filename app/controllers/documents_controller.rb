class DocumentsController < ApplicationController
  before_action :set_document, only: [ :show, :edit, :update, :destroy ]
  before_action :set_project, only: [ :index ]
  before_action :set_project_optional, only: [ :new, :create ]

  def index
    @documents = @project.documents
  end

  def show
    add_breadcrumb("Projects", projects_path)
    add_breadcrumb(@document.project.name, @document.project)
    add_breadcrumb(@document.title)
    @related_documents = @document.related_documents
  end

  def new
    add_breadcrumb("Projects", projects_path)
    if @project
      add_breadcrumb(@project.name, @project)
      @document = @project.documents.build
    else
      add_breadcrumb("New Document")
      @document = Document.new
    end
    @projects = Project.all
  end

  def create
    if params[:project_option] == "new"
      @project = Project.new(project_params)
      if @project.save
        @document = @project.documents.build(document_params)
      else
        @projects = Project.all
        @document = Document.new(document_params)
        @document.valid?
        render :new and return
      end
    else
      @project = Project.find(params[:project_id])
      @document = @project.documents.build(document_params)
    end


    if @document.save
      @document.content = document_params[:content]
      redirect_to [ @project, @document ], notice: "Document was successfully created."
    else
      @projects = Project.all
      render :new
    end
  end

  def edit
  end

  def update
    if @document.update(document_params)
      redirect_to @document, notice: "Document was successfully updated."
    else
      render :edit
    end
  end

  def destroy
    @document.destroy
    redirect_to @document.project, notice: "Document was successfully deleted."
  end

  private

  def set_document
    @document = Document.find(params[:id])
  end

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_project_optional
    @project = Project.find(params[:project_id]) if params[:project_id]
  end

  def document_params
    params.require(:document).permit(:title, :content)
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end
end
