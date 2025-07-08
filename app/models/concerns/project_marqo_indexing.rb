module ProjectMarqoIndexing
  extend ActiveSupport::Concern
  include MarqoIndexing

  MARQO_INDEX_NAME = "projects-index"
  MARQO_TENSOR_FIELDS = [ "name", "description" ]

  def to_marqo_document
    {
      "_id" => id.to_s,
      "name" => name,
      "description" => description,
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
