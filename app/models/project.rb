class Project < ApplicationRecord
  include ProjectMarqoIndexing
  include VectorSearchable

  has_many :documents, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true


  def to_search_result(hit)
    {
      id: id,
      name: name,
      description: description,
      document_count: documents.count,
      hightlights: hit["_highlights"],
      created_at: created_at,
      updated_at: updated_at,
      score: hit["_score"]
    }
  end

end
