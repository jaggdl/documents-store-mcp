class DocumentVector < ApplicationRecord
  belongs_to :document

  has_neighbors :embedding, dimensions: 768
end

