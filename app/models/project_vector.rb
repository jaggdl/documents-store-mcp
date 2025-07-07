class ProjectVector < ApplicationRecord
  belongs_to :project

  has_neighbors :embedding, dimensions: 768
end