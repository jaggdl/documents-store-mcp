module DocumentMarqoIndexing
  extend ActiveSupport::Concern
  include MarqoIndexing

  MARQO_INDEX_NAME = "documents-index"
  MARQO_TENSOR_FIELDS = [ "title", "content" ]

  def to_marqo_document
    {
      "_id" => id.to_s,
      "title" => title,
      "content" => content,
      "file_path" => file_path,
      "project_id" => project_id,
      "created_at" => created_at.iso8601,
      "updated_at" => updated_at.iso8601
    }
  end

  def marqo_index_name
    MARQO_INDEX_NAME
  end

  def marqo_tensor_fields
    MARQO_TENSOR_FIELDS
  end
end
