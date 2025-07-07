class UpdateDocumentEmbeddingJob < ApplicationJob
  queue_as :default
  
  def perform(file_path)
    relative_path = file_path.sub(Rails.root.to_s + "/", "")
    
    document = Document.find_by(file_path: relative_path)
    return unless document
    
    return unless File.exist?(file_path)
    
    new_content = File.read(file_path)
    
    if document.content != new_content
      document.update!(content: new_content)
      Rails.logger.info "Updated document content and embedding for: #{relative_path}"
    end
  rescue => e
    Rails.logger.error "Failed to update document embedding for #{file_path}: #{e.message}"
  end
end