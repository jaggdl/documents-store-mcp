class Document < ApplicationRecord
  belongs_to :project
  has_one :document_vector, dependent: :destroy

  validates :title, presence: true

  scope :search, ->(query) {
    all.select { |doc|
      doc.title.downcase.include?(query.downcase) ||
      doc.content.downcase.include?(query.downcase)
    }
  }

  before_save :generate_file_path, if: :new_record?
  after_save :ensure_file_exists
  after_commit :generate_embedding
  after_destroy :cleanup_file

  def content
    return "" unless file_path&.present? && File.exist?(absolute_file_path)
    File.read(absolute_file_path)
  end

  def content=(new_content)
    return unless file_path&.present?

    FileUtils.mkdir_p(File.dirname(absolute_file_path))
    File.write(absolute_file_path, new_content)
  end

  def content_as_html
    renderer = Redcarpet::Render::HTML.new(
      filter_html: true,
      no_images: false,
      no_links: false,
      no_styles: true,
      safe_links_only: true,
      with_toc_data: true,
      hard_wrap: true
    )

    markdown = Redcarpet::Markdown.new(renderer,
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true,
      superscript: true,
      underline: true,
      highlight: true,
      quote: true,
      footnotes: true
    )

    markdown.render(content).html_safe
  end

  def content_preview(length = 150)
    strip_tags(content_as_html).truncate(length)
  end


  def self.vector_search(query, limit: 10)
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


  def absolute_file_path
    return nil unless file_path
    Rails.root.join("public", file_path)
  end

  private

  def generate_file_path
    return if file_path.present?

    safe_title = title.gsub(/[^a-zA-Z0-9\-_]/, "_").downcase
    filename = "#{safe_title}_#{id || SecureRandom.hex(4)}.md"
    self.file_path = "documents/#{filename}"
  end

  def ensure_file_exists
    return unless file_path.present?

    FileUtils.mkdir_p(File.dirname(absolute_file_path))
    File.write(absolute_file_path, "") unless File.exist?(absolute_file_path)
  end

  def cleanup_file
    return unless file_path.present? && File.exist?(absolute_file_path)

    File.delete(absolute_file_path)
  end

  def strip_tags(html)
    ActionController::Base.helpers.strip_tags(html)
  end

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
