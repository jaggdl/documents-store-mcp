class DocumentResource < ApplicationResource
  uri 'documents/{id}'
  resource_name 'Document'
  description 'Individual document by ID'
  mime_type 'application/json'

  def content(uri = nil)
    document_id = extract_id_from_uri(uri)
    document = Document.includes(:project).find(document_id)
    JSON.generate({
      id: document.id,
      title: document.title,
      content: document.content,
      project: {
        id: document.project.id,
        name: document.project.name
      },
      created_at: document.created_at,
      updated_at: document.updated_at
    })
  rescue ActiveRecord::RecordNotFound
    JSON.generate({ error: "Document not found" })
  end

  private

  def extract_id_from_uri(uri_param = nil)
    actual_uri = uri_param || uri || self.class.uri
    actual_uri.split('/').last.to_i
  end
end