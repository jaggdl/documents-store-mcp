class Document < ApplicationRecord
  include DocumentFileManagement
  include DocumentContentProcessing
  include DocumentMarqoIndexing
  include VectorSearchable

  belongs_to :project

  validates :title, presence: true

  def project_other_documents
    project.documents.where.not(id:)
  end

  def related_documents(limit: 5)
    self.class.vector_recommend([ id.to_s ], limit:)
  end

  def to_search_result(hit)
    {
      id: id,
      title: title,
      project_name: project.name,
      highlights: hit["_highlights"],
      file_path: file_path,
      created_at: created_at,
      updated_at: updated_at,
      score: hit["_score"]
    }
  end
end
