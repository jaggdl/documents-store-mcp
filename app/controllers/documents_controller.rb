class DocumentsController < ApplicationController
  before_action :set_document, only: [ :show, :edit, :update, :destroy ]
  before_action :set_project, only: [ :index, :new, :create ]

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
    @document = @project.documents.build
  end

  def create
    @document = @project.documents.build(document_params)

    if @document.save
      redirect_to [ @project, @document ], notice: "Document was successfully created."
    else
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

  def document_params
    params.require(:document).permit(:title)
  end
end
