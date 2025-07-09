class MarqoSyncJob < ApplicationJob
  queue_as :default

  def perform(record_class, record_id)
    record = record_class.constantize.find_by(id: record_id)
    return unless record

    begin
      MarqoService.new(record.marqo_index_name).add_document(record.to_marqo_document, record.marqo_tensor_fields)
    rescue => e
      Rails.logger.error "Failed to sync #{record.class.name.downcase} #{record.id} to Marqo: #{e.message}"
    end
  end
end
