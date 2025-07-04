class ProjectDeleteTool < FastMcp::Tool
  description "Delete a project and all its documents"


  arguments do
    required(:project_id).filled(:integer).description("Project ID")
  end

  def call(project_id:)
    project = Project.find(project_id)
    project.destroy!
    { message: "Project deleted successfully" }
  rescue ActiveRecord::RecordNotFound
    raise "Project not found"
  end
end