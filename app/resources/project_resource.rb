class ProjectResource < ApplicationResource
  uri "projects/{id}"
  resource_name "Project"
  description "Individual project by ID"
  mime_type "application/json"

  def content(uri = nil)
    project_id = extract_id_from_uri(uri)
    project = Project.find(project_id)
    JSON.generate({
      id: project.id,
      name: project.name,
      description: project.description,
      documents_count: project.documents.count,
      created_at: project.created_at,
      updated_at: project.updated_at
    })
  rescue ActiveRecord::RecordNotFound
    JSON.generate({ error: "Project not found" })
  end

  private

  def extract_id_from_uri(uri_param = nil)
    actual_uri = uri_param || uri || self.class.uri
    actual_uri.split("/").last.to_i
  end
end
