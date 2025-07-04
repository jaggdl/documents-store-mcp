class Document < ApplicationRecord
  belongs_to :project
  
  validates :title, presence: true
  validates :content, presence: true
  
  scope :search, ->(query) { where("title LIKE ? OR content LIKE ?", "%#{query}%", "%#{query}%") }
end
