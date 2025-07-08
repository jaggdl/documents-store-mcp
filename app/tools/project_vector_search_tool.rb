class ProjectVectorSearchTool < ApplicationTool
  description "Search projects using semantic similarity via Marqo"

  arguments do
    required(:query).filled(:string).description("Search query to find semantically similar projects")
    optional(:limit).filled(:integer).description("Maximum number of results to return (default: 10)")
  end

  def call(query:, limit: 10)
    Project.vector_search(query, limit: limit)
  end
end
