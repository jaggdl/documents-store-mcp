class ProjectWithDocumentCreateTool < ApplicationTool
  description "Create a new project and its first document in one operation"

  arguments do
    required(:project_name).filled(:string).description("Project name")
    required(:project_description).filled(:string).description("Project description")
    required(:document_title).filled(:string).description("Document title")
    required(:markdown_content).filled(:string).description("Document content in markdown format")
  end

  def call(project_name:, project_description:, document_title:, markdown_content:)
    ActiveRecord::Base.transaction do
      project = Project.create!(
        name: project_name,
        description: project_description
      )

      document = project.documents.create!(
        title: document_title
      )
      document.content = markdown_content

      {
        project: {
          id: project.id,
          name: project.name,
          description: project.description,
          documents_count: project.documents.count,
          created_at: project.created_at,
          updated_at: project.updated_at
        },
        document: {
          id: document.id,
          title: document.title,
          file_path: document.file_path,
          absolute_file_path: document.absolute_file_path.to_s,
          created_at: document.created_at,
          updated_at: document.updated_at
        }
      }
    end
  rescue ActiveRecord::RecordInvalid => e
    raise "Validation failed: #{e.message}"
  end
end
