class DocumentReadTool < FastMcp::Tool
  description "Read a specific document"


  arguments do
    required(:document_id).filled(:integer).description("Document ID")
  end

  def call(document_id:)
    document = Document.includes(:project).find(document_id)
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
  rescue ActiveRecord::RecordNotFound
    raise "Document not found"
  end
end