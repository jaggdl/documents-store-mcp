class ProjectListTool < FastMcp::Tool
  description "List all projects"


  def call
    projects = Project.all
    projects.map do |project|
      {
        id: project.id,
        name: project.name,
        description: project.description,
        documents_count: project.documents.count,
        created_at: project.created_at,
        updated_at: project.updated_at
      }
    end
  end
end