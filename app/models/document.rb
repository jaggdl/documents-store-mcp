class Document < ApplicationRecord
  include DocumentFileManagement
  include DocumentContentProcessing
  include DocumentVectorSearch

  belongs_to :project
  has_one :document_vector, dependent: :destroy

  validates :title, presence: true

  scope :search, ->(query) {
    all.select { |doc|
      doc.title.downcase.include?(query.downcase) ||
      doc.content.downcase.include?(query.downcase)
    }
  }
end
