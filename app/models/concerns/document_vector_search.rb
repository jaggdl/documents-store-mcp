module DocumentVectorSearch
  extend ActiveSupport::Concern

  included do
    after_commit :generate_embedding
  end

  class_methods do
    def vector_search(query, limit: 10)
      return [] unless query.present?

      begin
        query_embedding = EmbeddingService.generate_embedding(query)

        nearest_vectors = DocumentVector.nearest_neighbors(
          :embedding,
          query_embedding,
          distance: "cosine"
        ).limit(limit)

        nearest_vectors.includes(:document).map(&:document)
      rescue => e
        Rails.logger.error "Vector search error: #{e.message}"
        []
      end
    end
  end

  private

  def generate_embedding
    return unless content.present?

    begin
      embedding_vector = EmbeddingService.generate_embedding(content)

      if document_vector
        document_vector.update!(embedding: embedding_vector)
      else
        create_document_vector!(embedding: embedding_vector)
      end
    rescue => e
      Rails.logger.error "Failed to generate embedding for document #{id}: #{e.message}"
    end
  end
end