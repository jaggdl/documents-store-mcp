class DocumentCreateTool < ApplicationTool
  description "Create a new document in markdown format"


  arguments do
    required(:title).filled(:string).description("Document title")
    required(:content).filled(:string).description("Document content in markdown format")
    required(:project_id).filled(:integer).description("Project ID to associate the document with")
  end

  def call(title:, content:, project_id:)
    project = Project.find(project_id)
    document = project.documents.create!(title: title, content: content)
    {
      id: document.id,
      title: document.title,
      content: document.content,
      project: {
        id: project.id,
        name: project.name
      },
      created_at: document.created_at,
      updated_at: document.updated_at
    }
  rescue ActiveRecord::RecordNotFound
    raise "Project not found"
  rescue ActiveRecord::RecordInvalid => e
    raise "Validation failed: #{e.message}"
  end
end