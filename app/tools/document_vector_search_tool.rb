class DocumentVectorSearchTool < ApplicationTool
  description "Search documents using vector similarity based on semantic meaning"

  arguments do
    required(:query).filled(:string).description("Search query to find semantically similar documents")
    optional(:limit).filled(:integer).description("Maximum number of results to return (default: 10)")
    optional(:project_id).filled(:integer).description("Limit search to specific project")
  end

  def call(query:, limit: 10, project_id: nil)
    documents = if project_id
      Document.where(project_id: project_id).vector_search(query, limit: limit)
    else
      Document.vector_search(query, limit: limit)
    end

    if documents.empty?
      return {
        message: "No documents found matching your query",
        results: [],
        _meta: {
          search_query: query,
          search_type: "vector_search",
          results_count: 0
        }
      }
    end

    results = documents.map do |doc|
      {
        id: doc.id,
        title: doc.title,
        project_name: doc.project.name,
        content_preview: doc.content_preview(200),
        file_path: doc.file_path,
        created_at: doc.created_at,
        updated_at: doc.updated_at
      }
    end

    {
      message: "Found #{documents.length} documents matching your query",
      results: results,
      _meta: {
        search_query: query,
        search_type: "vector_search",
        results_count: documents.length,
        limit: limit
      }
    }
  end
end

