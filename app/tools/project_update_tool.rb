class ProjectUpdateTool < ApplicationTool
  description "Update a project"


  arguments do
    required(:project_id).filled(:integer).description("Project ID")
    optional(:name).filled(:string).description("Updated project name")
    optional(:description).filled(:string).description("Updated project description")
  end

  def call(project_id:, name: nil, description: nil)
    project = Project.find(project_id)
    project.update!(name: name) if name
    project.update!(description: description) if description
    {
      id: project.id,
      name: project.name,
      description: project.description,
      documents_count: project.documents.count,
      created_at: project.created_at,
      updated_at: project.updated_at
    }
  rescue ActiveRecord::RecordNotFound
    raise "Project not found"
  rescue ActiveRecord::RecordInvalid => e
    raise "Validation failed: #{e.message}"
  end
end