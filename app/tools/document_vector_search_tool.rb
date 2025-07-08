class DocumentVectorSearchTool < ApplicationTool
  description "Search documents using semantic similarity via Marqo"

  arguments do
    required(:query).filled(:string).description("Search query to find semantically similar documents")
    optional(:limit).filled(:integer).description("Maximum number of results to return (default: 10)")
    optional(:project_id).filled(:integer).description("Limit search to specific project")
  end

  def call(query:, limit: 10, project_id: nil)
    marqo_service = MarqoService.new
    search_results = marqo_service.search_documents(query, limit: limit)
    
    if search_results["hits"].empty?
      return {
        message: "No documents found matching your query",
        results: [],
        _meta: {
          search_query: query,
          search_type: "marqo_search",
          results_count: 0
        }
      }
    end

    results = search_results["hits"].map do |hit|
      document_id = hit["_id"].to_i
      
      next unless document_id > 0
      
      if project_id && hit["project_id"] != project_id
        next
      end
      
      document = Document.find_by(id: document_id)
      next unless document
      
      {
        id: document.id,
        title: document.title,
        project_name: document.project.name,
        highlights: extract_highlights(hit),
        file_path: document.file_path,
        created_at: document.created_at,
        updated_at: document.updated_at,
        score: hit["_score"]
      }
    end.compact

    if project_id
      results = results.select { |r| r[:project_name] == Project.find(project_id).name }
    end

    {
      message: "Found #{results.length} documents matching your query",
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
    
    if hit["_highlights"] && hit["_highlights"]["content"]
      highlights = hit["_highlights"]["content"].map { |h| h.gsub(/<\/?mark>/, "") }
    end
    
    if highlights.empty? && hit["content"]
      highlights = [hit["content"][0..200] + "..."]
    end
    
    highlights
  end
end

