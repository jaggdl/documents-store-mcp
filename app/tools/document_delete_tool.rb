class DocumentDeleteTool < ApplicationTool
  description "Delete a document"


  arguments do
    required(:document_id).filled(:integer).description("Document ID")
  end

  def call(document_id:)
    document = Document.find(document_id)
    document.destroy!
    { message: "Document deleted successfully" }
  rescue ActiveRecord::RecordNotFound
    raise "Document not found"
  end
end