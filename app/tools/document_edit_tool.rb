class DocumentEditTool < ApplicationTool
  description "Edit a document using a unified diff format"

  arguments do
    required(:document_id).filled(:integer).description("Document ID")
    optional(:title).filled(:string).description("Updated document title")
    optional(:diff).filled(:string).description("Unified diff format to apply to the document content")
  end

  def call(document_id:, title: nil, diff: nil)
    document = Document.includes(:project).find(document_id)

    document.update!(title: title) if title

    if diff
      original_content = document.content
      new_content = apply_diff(original_content, diff)
      document.update!(content: new_content)
    end

    {
      id: document.id,
      title: document.title,
      content: document.content,
      project: {
        id: document.project.id,
        name: document.project.name
      },
      created_at: document.created_at,
      updated_at: document.updated_at
    }
  rescue ActiveRecord::RecordNotFound
    raise "Document not found"
  rescue ActiveRecord::RecordInvalid => e
    raise "Validation failed: #{e.message}"
  end

  private

  def apply_diff(original_content, diff)
    original_lines = original_content.split("\n")
    diff_lines = diff.split("\n")

    result_lines = []
    original_index = 0

    i = 0
    while i < diff_lines.length
      line = diff_lines[i]

      if line.start_with?("@@")
        hunk_header = parse_hunk_header(line)
        old_start = hunk_header[:old_start] - 1

        while original_index < old_start && original_index < original_lines.length
          result_lines << original_lines[original_index]
          original_index += 1
        end

        i += 1
        while i < diff_lines.length && !diff_lines[i].start_with?("@@")
          diff_line = diff_lines[i]

          if diff_line.start_with?(" ")
            result_lines << diff_line[1..-1]
            original_index += 1
          elsif diff_line.start_with?("-")
            original_index += 1
          elsif diff_line.start_with?("+")
            result_lines << diff_line[1..-1]
          end

          i += 1
        end

        i -= 1
      end

      i += 1
    end

    while original_index < original_lines.length
      result_lines << original_lines[original_index]
      original_index += 1
    end

    result_lines.join("\n")
  end

  def parse_hunk_header(header)
    match = header.match(/@@ -(\d+)(?:,(\d+))? \+(\d+)(?:,(\d+))? @@/)
    return {} unless match

    {
      old_start: match[1].to_i,
      old_count: match[2]&.to_i || 1,
      new_start: match[3].to_i,
      new_count: match[4]&.to_i || 1
    }
  end
end
