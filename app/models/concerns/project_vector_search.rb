module ProjectVectorSearch
  extend ActiveSupport::Concern

  included do
    after_commit :generate_embedding
  end

  class_methods do
    def vector_search(query, limit: 10)
      return [] unless query.present?

      begin
        query_embedding = EmbeddingService.generate_embedding(query)

        nearest_vectors = ProjectVector.nearest_neighbors(
          :embedding,
          query_embedding,
          distance: "cosine"
        ).limit(limit)

        nearest_vectors.includes(:project).map(&:project)
      rescue => e
        Rails.logger.error "Project vector search error: #{e.message}"
        []
      end
    end
  end

  def searchable_content
    content_parts = [ name, description ]

    document_titles = documents.pluck(:title)
    document_content_previews = documents.limit(10).map { |doc| doc.content_preview(100) }

    content_parts.concat(document_titles)
    content_parts.concat(document_content_previews)

    content_parts.reject(&:blank?).join(" ")
  end

  def content_highlights(query, max_highlights: 3, snippet_length: 150)
    return [ description.truncate(snippet_length) ] if query.blank?

    text = "#{name} #{description}"
    return [ text.truncate(snippet_length) ] if text.length <= snippet_length

    query_terms = query.downcase.split(/\s+/).reject(&:blank?)
    return [ text.truncate(snippet_length) ] if query_terms.empty?

    highlights = []

    query_terms.each do |term|
      text.scan(/(.{0,#{snippet_length/3}}#{Regexp.escape(term)}.{0,#{snippet_length/3}})/i) do |match|
        snippet = match[0].strip
        next if snippet.length < 10

        highlights << {
          text: snippet,
          score: calculate_snippet_score(snippet, query_terms),
          term: term
        }
      end
    end

    if highlights.empty?
      sentences = text.split(/[.!?]+/).reject(&:blank?)
      scored_sentences = sentences.map do |sentence|
        {
          text: sentence.strip,
          score: calculate_snippet_score(sentence, query_terms),
          term: "context"
        }
      end

      highlights = scored_sentences.select { |s| s[:score] > 0 }
    end

    highlights.sort_by { |h| -h[:score] }
             .take(max_highlights)
             .map { |h| h[:text].truncate(snippet_length) }
             .reject(&:blank?)
             .presence || [ description.truncate(snippet_length) ]
  end

  private

  def calculate_snippet_score(text, query_terms)
    text_lower = text.downcase
    score = 0

    query_terms.each do |term|
      term_count = text_lower.scan(term.downcase).length
      score += term_count * 10

      if text_lower.include?(term.downcase)
        score += 5
      end
    end

    score += text.length > 50 ? 2 : 0
    score
  end

  def generate_embedding
    content = searchable_content
    return unless content.present?

    begin
      embedding_vector = EmbeddingService.generate_embedding(content)

      if project_vector
        project_vector.update!(embedding: embedding_vector)
      else
        create_project_vector!(embedding: embedding_vector)
      end
    rescue => e
      Rails.logger.error "Failed to generate embedding for project #{id}: #{e.message}"
    end
  end
end

