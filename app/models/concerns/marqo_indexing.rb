module MarqoIndexing
  extend ActiveSupport::Concern

  included do
    after_commit :sync_to_marqo, on: [ :create, :update ]
    after_commit :remove_from_marqo, on: :destroy
  end

  private

  def sync_to_marqo
    return unless persisted?

    begin
      MarqoService.new(marqo_index_name).add_document(to_marqo_document, marqo_tensor_fields)
    rescue => e
      Rails.logger.error "Failed to sync #{self.class.name.downcase} #{id} to Marqo: #{e.message}"
    end
  end

  def remove_from_marqo
    begin
      MarqoService.new(marqo_index_name).delete_document(id)
    rescue => e
      Rails.logger.error "Failed to remove #{self.class.name.downcase} #{id} from Marqo: #{e.message}"
    end
  end
end