require "test_helper"

class ProjectResourceTest < ActiveSupport::TestCase
  def setup
    Project.destroy_all
    Document.destroy_all
    @project = Project.create!(name: "Test Project", description: "Test project description")
    @document = Document.create!(title: "Doc 1", content: "Content 1", project: @project)
    @resource = ProjectResource.new
  end

  test "should return project with correct structure" do
    content = @resource.content("projects/#{@project.id}")
    project = JSON.parse(content)
    
    assert_equal @project.id, project["id"]
    assert_equal @project.name, project["name"]
    assert_equal @project.description, project["description"]
    assert_equal 1, project["documents_count"]
    assert_not_nil project["created_at"]
    assert_not_nil project["updated_at"]
  end

  test "should return error for non-existent project" do
    content = @resource.content("projects/99999")
    result = JSON.parse(content)
    
    assert_equal "Project not found", result["error"]
  end

  test "should handle project with no documents" do
    @document.destroy
    
    content = @resource.content("projects/#{@project.id}")
    project = JSON.parse(content)
    
    assert_equal 0, project["documents_count"]
  end

  test "should have correct resource metadata" do
    assert_equal 'projects/{id}', @resource.class.uri
    assert_equal 'Project', @resource.class.resource_name
    assert_equal 'Individual project by ID', @resource.class.description
    assert_equal 'application/json', @resource.class.mime_type
  end

  test "should extract id from uri correctly" do
    id = @resource.send(:extract_id_from_uri, "projects/123")
    assert_equal 123, id
  end
end