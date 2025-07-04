class ProjectsResource < ApplicationResource
  uri 'projects'
  resource_name 'Projects'
  description 'All projects in the document store'
  mime_type 'application/json'

  def content
    projects = Project.all
    JSON.generate(projects.map do |project|
      {
        id: project.id,
        name: project.name,
        description: project.description,
        documents_count: project.documents.count,
        created_at: project.created_at,
        updated_at: project.updated_at
      }
    end)
  end
end