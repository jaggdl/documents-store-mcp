class ProjectVectorSearchTool < ApplicationTool
  description "Search projects using semantic similarity via Marqo"

  arguments do
    required(:query).filled(:string).description("Search query to find semantically similar projects")
    optional(:limit).filled(:integer).description("Maximum number of results to return (default: 10)")
  end

  def call(query:, limit: 10)
    marqo_service = MarqoService.new
    search_results = marqo_service.search_projects(query, limit: limit)
    
    if search_results["hits"].empty?
      return {
        message: "No projects found matching your query",
        results: [],
        _meta: {
          search_query: query,
          search_type: "marqo_search",
          results_count: 0
        }
      }
    end

    results = search_results["hits"].map do |hit|
      project_id = hit["_id"].to_i
      
      next unless project_id > 0
      
      project = Project.find_by(id: project_id)
      next unless project
      
      {
        id: project.id,
        name: project.name,
        description: project.description,
        highlights: extract_highlights(hit),
        document_count: project.documents.count,
        created_at: project.created_at,
        updated_at: project.updated_at,
        score: hit["_score"]
      }
    end.compact

    {
      message: "Found #{results.length} projects matching your query",
      results: results,
      _meta: {
        search_query: query,
        search_type: "marqo_search",
        results_count: results.length,
        limit: limit
      }
    }
  end

  private

  def extract_highlights(hit)
    highlights = []
    
    if hit["_highlights"] && hit["_highlights"]["description"]
      highlights = hit["_highlights"]["description"].map { |h| h.gsub(/<\/?mark>/, "") }
    end
    
    if highlights.empty? && hit["description"]
      highlights = [hit["description"][0..200] + "..."]
    end
    
    highlights
  end
end