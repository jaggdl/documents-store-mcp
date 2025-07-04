class ProjectCreateTool < ApplicationTool
  description "Create a new project"

  arguments do
    required(:name).filled(:string).description("Project name")
    required(:description).filled(:string).description("Project description")
  end

  def call(name:, description:)
    project = Project.create!(name: name, description: description)
    {
      id: project.id,
      name: project.name,
      description: project.description,
      documents_count: 0,
      created_at: project.created_at,
      updated_at: project.updated_at
    }
  rescue ActiveRecord::RecordInvalid => e
    raise "Validation failed: #{e.message}"
  end
end