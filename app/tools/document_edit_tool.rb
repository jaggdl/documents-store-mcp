class DocumentEditTool < FastMcp::Tool
  description "Edit specific lines in a document"

  arguments do
    required(:document_id).filled(:integer).description("Document ID")
    optional(:title).filled(:string).description("Updated document title")
    optional(:line_edits).filled(:hash).description("Hash of line_number => new_content for specific line replacements")
    optional(:append_content).filled(:string).description("Content to append to the document")
    optional(:prepend_content).filled(:string).description("Content to prepend to the document")
  end

  def call(document_id:, title: nil, line_edits: nil, append_content: nil, prepend_content: nil)
    document = Document.includes(:project).find(document_id)
    
    document.update!(title: title) if title
    
    if line_edits || append_content || prepend_content
      lines = document.content.split("\n")
      
      line_edits&.each do |line_num, new_content|
        lines[line_num.to_i - 1] = new_content
      end
      
      lines.prepend(prepend_content) if prepend_content
      lines.append(append_content) if append_content
      
      document.update!(content: lines.join("\n"))
    end
    
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
  rescue ActiveRecord::RecordInvalid => e
    raise "Validation failed: #{e.message}"
  end
end