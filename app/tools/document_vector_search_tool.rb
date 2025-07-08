class DocumentVectorSearchTool < ApplicationTool
  description "Search documents using semantic similarity via Marqo"

  arguments do
    required(:query).filled(:string).description("Search query to find semantically similar documents")
    optional(:limit).filled(:integer).description("Maximum number of results to return (default: 10)")
    optional(:project_id).filled(:integer).description("Limit search to specific project")
  end

  def call(query:, limit: 10, project_id: nil)
    result = Document.vector_search(query, limit: limit)

    if project_id
      project = Project.find(project_id)
      result[:results] = result[:results].select { |r| r[:project_name] == project.name }
      result[:message] = "Found #{result[:results].length} documents matching your query"
    end

    result
  end
end
