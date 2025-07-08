module VectorSearchable
  extend ActiveSupport::Concern

  included do
    def self.vector_search(query, limit: 10)
      index_name = new.marqo_index_name
      marqo_service = MarqoService.new(index_name)
      search_results = marqo_service.search(query, limit: limit)

      if search_results["hits"].empty?
        return {
          message: "No #{model_name.plural.downcase} found matching your query",
          results: []
        }
      end

      results = search_results["hits"].filter_map do |hit|
        record_id = hit["_id"].to_i
        next unless record_id > 0

        record = find_by(id: record_id)
        next unless record

        record.to_search_result(hit)
      end

      {
        message: "Found #{results.length} #{model_name.plural.downcase} matching your query",
        results: results
      }
    end
  end

  def to_search_result(hit)
    raise NotImplementedError, "#{self.class} must implement to_search_result method"
  end
end
