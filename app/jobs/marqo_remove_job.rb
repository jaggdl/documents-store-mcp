class MarqoRemoveJob < ApplicationJob
  queue_as :default

  def perform(record_class, record_id, index_name)
    begin
      MarqoService.new(index_name).delete_document(record_id)
    rescue => e
      Rails.logger.error "Failed to remove #{record_class.downcase} #{record_id} from Marqo: #{e.message}"
    end
  end
end
