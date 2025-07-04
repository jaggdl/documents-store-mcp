require "test_helper"

class ProjectsResourceTest < ActiveSupport::TestCase
  def setup
    Project.destroy_all
    Document.destroy_all
    @project1 = Project.create!(name: "Test Project 1", description: "Test project 1 description")
    @project2 = Project.create!(name: "Test Project 2", description: "Test project 2 description")
    @document1 = Document.create!(title: "Doc 1", content: "Content 1", project: @project1)
    @document2 = Document.create!(title: "Doc 2", content: "Content 2", project: @project1)
    @resource = ProjectsResource.new
  end

  test "should return all projects with correct structure" do
    content = @resource.content
    projects = JSON.parse(content)
    
    assert_equal 2, projects.length
    
    project = projects.find { |p| p["id"] == @project1.id }
    assert_not_nil project
    assert_equal @project1.name, project["name"]
    assert_equal @project1.description, project["description"]
    assert_equal 2, project["documents_count"]
    assert_not_nil project["created_at"]
    assert_not_nil project["updated_at"]
  end

  test "should return empty array when no projects exist" do
    Project.destroy_all
    
    content = @resource.content
    projects = JSON.parse(content)
    
    assert_equal [], projects
  end

  test "should handle projects with no documents" do
    content = @resource.content
    projects = JSON.parse(content)
    
    project = projects.find { |p| p["id"] == @project2.id }
    assert_not_nil project
    assert_equal 0, project["documents_count"]
  end

  test "should have correct resource metadata" do
    assert_equal 'projects', @resource.class.uri
    assert_equal 'Projects', @resource.class.resource_name
    assert_equal 'All projects in the document store', @resource.class.description
    assert_equal 'application/json', @resource.class.mime_type
  end
end