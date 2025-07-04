class ProjectReadTool < FastMcp::Tool
  description "Read a specific project"


  arguments do
    required(:project_id).filled(:integer).description("Project ID")
  end

  def call(project_id:)
    project = Project.find(project_id)
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
  end
end