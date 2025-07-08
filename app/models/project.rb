class Project < ApplicationRecord
  has_many :documents, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :description, presence: true

  after_commit :sync_to_marqo, on: [:create, :update]
  after_commit :remove_from_marqo, on: :destroy

  private

  def sync_to_marqo
    return unless persisted?
    
    begin
      MarqoService.new.add_project(self)
    rescue => e
      Rails.logger.error "Failed to sync project #{id} to Marqo: #{e.message}"
    end
  end

  def remove_from_marqo
    begin
      MarqoService.new.delete_project(id)
    rescue => e
      Rails.logger.error "Failed to remove project #{id} from Marqo: #{e.message}"
    end
  end
end
