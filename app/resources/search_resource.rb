class SearchResource < ApplicationResource
  uri "search/{query}"
  resource_name "Search"
  description "Search documents by query"
  mime_type "application/json"

  def content(uri = nil)
    query = extract_query_from_uri(uri)
    return JSON.generate([]) if query.blank?

    documents = Document.search(query).includes(:project)

    JSON.generate({
      search_query: query,
      results_count: documents.count,
      results: documents.map do |document|
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
    })
  end

  private

  def extract_query_from_uri(uri_param = nil)
    actual_uri = uri_param || uri || self.class.uri
    parts = actual_uri.split("/")
    return "" if parts.length < 2
    query = parts.last.gsub("%20", " ")
    query == "{query}" || query.empty? ? "" : query
  end
end
