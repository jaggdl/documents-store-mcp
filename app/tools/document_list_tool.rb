class DocumentListTool < FastMcp::Tool
  description "List documents, optionally filtered by project"


  arguments do
    optional(:project_id).filled(:integer).description("Project ID to filter documents by")
  end

  def call(project_id: nil)
    documents = project_id ? Document.where(project_id: project_id) : Document.all
    documents.includes(:project).map do |document|
      {
        id: document.id,
        title: document.title,
        content: document.content,
        project: {
          id: document.project.id,
          name: document.project.name
        },
        created_at: document.created_at,
        updated_at: document.updated_at
      }
    end
  end
end