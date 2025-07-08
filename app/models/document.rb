class Document < ApplicationRecord
  include DocumentFileManagement
  include DocumentContentProcessing

  belongs_to :project

  validates :title, presence: true

  scope :search, ->(query) {
    all.select { |doc|
      doc.title.downcase.include?(query.downcase) ||
      doc.content.downcase.include?(query.downcase)
    }
  }

  after_commit :sync_to_marqo, on: [:create, :update]
  after_commit :remove_from_marqo, on: :destroy

  private

  def sync_to_marqo
    return unless persisted?
    
    begin
      MarqoService.new.add_document(self)
    rescue => e
      Rails.logger.error "Failed to sync document #{id} to Marqo: #{e.message}"
    end
  end

  def remove_from_marqo
    begin
      MarqoService.new.delete_document(id)
    rescue => e
      Rails.logger.error "Failed to remove document #{id} from Marqo: #{e.message}"
    end
  end
end
