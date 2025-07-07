class Project < ApplicationRecord
  include ProjectVectorSearch

  has_many :documents, dependent: :destroy
  has_one :project_vector, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
end
