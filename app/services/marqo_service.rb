class MarqoService
  MARQO_URL = ENV.fetch("MARQO_URL", "http://localhost:8882")
  DOCUMENTS_INDEX = "documents-index"
  PROJECTS_INDEX = "projects-index"

  def initialize
    @base_url = MARQO_URL
  end

  def create_indexes
    create_index(DOCUMENTS_INDEX, "hf/e5-base-v2")
    create_index(PROJECTS_INDEX, "hf/e5-base-v2")
  end

  def add_document(document)
    doc_data = {
      "_id" => document.id.to_s,
      "title" => document.title,
      "content" => document.content,
      "file_path" => document.file_path,
      "project_id" => document.project_id,
      "created_at" => document.created_at.iso8601,
      "updated_at" => document.updated_at.iso8601
    }

    add_documents_to_index(DOCUMENTS_INDEX, [ doc_data ], [ "title", "content" ])
  end

  def add_project(project)
    project_data = {
      "_id" => project.id.to_s,
      "name" => project.name,
      "description" => project.description,
      "created_at" => project.created_at.iso8601,
      "updated_at" => project.updated_at.iso8601
    }

    add_documents_to_index(PROJECTS_INDEX, [ project_data ], [ "name", "description" ])
  end

  def search_documents(query, limit: 10)
    search_index(DOCUMENTS_INDEX, query, limit)
  end

  def search_projects(query, limit: 10)
    search_index(PROJECTS_INDEX, query, limit)
  end

  def delete_document(document_id)
    delete_from_index(DOCUMENTS_INDEX, document_id.to_s)
  end

  def delete_project(project_id)
    delete_from_index(PROJECTS_INDEX, project_id.to_s)
  end

  private

  def create_index(index_name, model)
    uri = URI("#{@base_url}/indexes/#{index_name}")
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
