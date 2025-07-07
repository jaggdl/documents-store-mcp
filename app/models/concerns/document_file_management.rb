module DocumentFileManagement
  extend ActiveSupport::Concern

  included do
    before_save :generate_file_path, if: :new_record?
    after_save :ensure_file_exists
    after_destroy :cleanup_file
  end

  def content
    return "" unless file_path&.present? && File.exist?(absolute_file_path)
    File.read(absolute_file_path)
  end

  def content=(new_content)
    return unless file_path&.present?

    FileUtils.mkdir_p(File.dirname(absolute_file_path))
    File.write(absolute_file_path, new_content)
  end

  def absolute_file_path
    return nil unless file_path
    Rails.root.join("public", file_path)
  end

  private

  def generate_file_path
    return if file_path.present?

    safe_title = title.gsub(/[^a-zA-Z0-9\-_]/, "_").downcase
    filename = "#{safe_title}_#{id || SecureRandom.hex(4)}.md"
    self.file_path = "documents/#{filename}"
  end

  def ensure_file_exists
    return unless file_path.present?

    FileUtils.mkdir_p(File.dirname(absolute_file_path))
    File.write(absolute_file_path, "") unless File.exist?(absolute_file_path)
  end

  def cleanup_file
    return unless file_path.present? && File.exist?(absolute_file_path)

    File.delete(absolute_file_path)
  end
end