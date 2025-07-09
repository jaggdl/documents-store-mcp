require "net/http"
require "json"

class MarqoService
  MARQO_URL = ENV.fetch("MARQO_URL", "http://localhost:8882")

  class << self
    def create_indexes
      create_index(DocumentMarqoIndexing::MARQO_INDEX_NAME, "hf/e5-base-v2")
      create_index(ProjectMarqoIndexing::MARQO_INDEX_NAME, "hf/e5-base-v2")
    end

    def create_index(index_name, model)
      uri = URI("#{MARQO_URL}/indexes/#{index_name}")
      http = Net::HTTP.new(uri.host, uri.port)

      request = Net::HTTP::Post.new(uri)
      request["Content-Type"] = "application/json"
      request.body = {
        model: model,
        type: "unstructured",
        textPreprocessing: {
          splitLength: 2,
          splitOverlap: 0,
          splitMethod: "sentence"
        }
      }.to_json

      response = http.request(request)

      if response.code == "200" || response.code == "409"
        Rails.logger.info "Index #{index_name} created or already exists"
      else
        Rails.logger.error "Failed to create index #{index_name}: #{response.body}"
      end
    end
  end

  def initialize(index_name = nil)
    @base_url = MARQO_URL
    @index_name = index_name
  end


  def add_document(document_data, tensor_fields)
    add_documents_to_index(@index_name, [ document_data ], tensor_fields)
  end

  def search(query, limit: 10)
    search_index(@index_name, query, limit)
  end

  def recommend(document_ids, limit: 10)
    recommend_from_index(@index_name, document_ids, limit)
  end

  def delete_document(document_id)
    delete_from_index(@index_name, document_id.to_s)
  end

  private


  def add_documents_to_index(index_name, documents, tensor_fields)
    uri = URI("#{@base_url}/indexes/#{index_name}/documents")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = {
      documents: documents,
      tensorFields: tensor_fields
    }.to_json

    response = http.request(request)

    unless response.code == "200"
      Rails.logger.error "Failed to add documents to #{index_name}: #{response.body}"
      raise "Failed to add documents to Marqo index"
    end
  end

  def search_index(index_name, query, limit)
    uri = URI("#{@base_url}/indexes/#{index_name}/search")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = {
      q: query,
      limit: limit,
      showHighlights: true
    }.to_json

    response = http.request(request)

    if response.code == "200"
      JSON.parse(response.body)
    else
      Rails.logger.error "Failed to search #{index_name}: #{response.body}"
      { "hits" => [] }
    end
  end

  def recommend_from_index(index_name, document_ids, limit)
    uri = URI("#{@base_url}/indexes/#{index_name}/recommend")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri)
    request["Content-Type"] = "application/json"
    request.body = {
      documents: document_ids,
      limit: limit,
      showHighlights: true
    }.to_json

    response = http.request(request)

    if response.code == "200"
      JSON.parse(response.body)
    else
      Rails.logger.error "Failed to get recommendations from #{index_name}: #{response.body}"
      { "hits" => [] }
    end
  end

  def delete_from_index(index_name, document_id)
    uri = URI("#{@base_url}/indexes/#{index_name}/documents/#{document_id}")
    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Delete.new(uri)
    response = http.request(request)

    unless response.code == "200"
      Rails.logger.error "Failed to delete document #{document_id} from #{index_name}: #{response.body}"
    end
  end
end
