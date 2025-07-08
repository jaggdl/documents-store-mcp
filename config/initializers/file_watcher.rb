Rails.application.config.after_initialize do
  FileWatcherService.start
end
