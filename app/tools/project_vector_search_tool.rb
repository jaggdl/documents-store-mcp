class ProjectVectorSearchTool < ApplicationTool
  description "Search projects using vector similarity based on semantic meaning"

  arguments do
    required(:query).filled(:string).description("Search query to find semantically similar projects")
    optional(:limit).filled(:integer).description("Maximum number of results to return (default: 10)")
  end

  def call(query:, limit: 10)
    projects = Project.vector_search(query, limit: limit)

    if projects.empty?
      return {
        message: "No projects found matching your query",
        results: [],
        _meta: {
          search_query: query,
          search_type: "project_vector_search",
          results_count: 0
        }
      }
    end

    results = projects.map do |project|
      {
        id: project.id,
        name: project.name,
        description: project.description,
        highlights: project.content_highlights(query, max_highlights: 3, snippet_length: 200),
        document_count: project.documents.count,
        created_at: project.created_at,
        updated_at: project.updated_at
      }
    end

    {
      message: "Found #{projects.length} projects matching your query",
      results: results,
      _meta: {
        search_query: query,
        search_type: "project_vector_search",
        results_count: projects.length,
        limit: limit
      }
    }
  end
end