class FileWatcherService
  def self.start
    return unless Rails.env.development? || Rails.env.production?

    documents_path = Rails.root.join("public", "documents")

    return unless File.directory?(documents_path)

    Thread.new do
      listener = Listen.to(documents_path, only: /\.md$/) do |modified, added, removed|
        handle_file_changes(modified, added, removed)
      end

      listener.start
      Rails.logger.info "File watcher started for #{documents_path}"

      sleep
    end
  end

  private

  def self.handle_file_changes(modified, added, removed)
    (modified + added).each do |file_path|
      UpdateDocumentEmbeddingJob.perform_later(file_path)
    end

    removed.each do |file_path|
      Rails.logger.info "Document file removed: #{file_path}"
    end
  end
end

