class DocumentsResource < ApplicationResource
  uri 'documents'
  resource_name 'Documents'
  description 'All documents in the document store'
  mime_type 'application/json'

  def content
    documents = Document.includes(:project).all
    JSON.generate(documents.map do |document|
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
    end)
  end
end