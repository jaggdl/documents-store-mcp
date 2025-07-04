class DocumentSearchTool < FastMcp::Tool
  description "Search for documents by content or title"


  arguments do
    required(:query).filled(:string).description("Search query to find in document titles or content")
    optional(:project_id).filled(:integer).description("Project ID to limit search to specific project")
  end

  def call(query:, project_id: nil)
    documents = project_id ? Document.where(project_id: project_id) : Document.all
    results = documents.search(query).includes(:project)
    
    _meta[:search_query] = query
    _meta[:results_count] = results.count
    _meta[:project_filtered] = !project_id.nil?
    
    results.map do |document|
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