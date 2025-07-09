module MarqoIndexing
  extend ActiveSupport::Concern

  included do
    after_commit :sync_to_marqo, on: [ :create, :update ]
    after_commit :remove_from_marqo, on: :destroy
  end

  private

  def sync_to_marqo
    return unless persisted?

    MarqoSyncJob.perform_later(self.class.name, id)
  end

  def remove_from_marqo
    MarqoRemoveJob.perform_later(self.class.name, id, marqo_index_name)
  end
end
