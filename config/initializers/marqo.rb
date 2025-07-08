Rails.application.config.after_initialize do
  next if Rails.env.test? || ENV["SKIP_MARQO_INIT"]

  begin
    marqo_service = MarqoService.new
    marqo_service.create_indexes
    Rails.logger.info "Marqo indexes created successfully"
  rescue => e
    Rails.logger.error "Failed to create Marqo indexes: #{e.message}"
  end
end
