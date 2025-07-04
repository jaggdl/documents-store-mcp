require "test_helper"

class DocumentResourceTest < ActiveSupport::TestCase
  def setup
    Project.destroy_all
    Document.destroy_all
    @project = Project.create!(name: "Test Project", description: "Test project description")
    @document = Document.create!(title: "Test Document", content: "Test content", project: @project)
    @resource = DocumentResource.new
  end

  test "should return document with correct structure" do
    content = @resource.content("documents/#{@document.id}")
    document = JSON.parse(content)
    
    assert_equal @document.id, document["id"]
    assert_equal @document.title, document["title"]
    assert_equal @document.content, document["content"]
    assert_equal @project.id, document["project"]["id"]
    assert_equal @project.name, document["project"]["name"]
    assert_not_nil document["created_at"]
    assert_not_nil document["updated_at"]
  end

  test "should return error for non-existent document" do
    content = @resource.content("documents/99999")
    result = JSON.parse(content)
    
    assert_equal "Document not found", result["error"]
  end

  test "should include project information" do
    content = @resource.content("documents/#{@document.id}")
    document = JSON.parse(content)
    
    assert_not_nil document["project"]
    assert_equal @project.id, document["project"]["id"]
    assert_equal @project.name, document["project"]["name"]
  end

  test "should have correct resource metadata" do
    assert_equal 'documents/{id}', @resource.class.uri
    assert_equal 'Document', @resource.class.resource_name
    assert_equal 'Individual document by ID', @resource.class.description
    assert_equal 'application/json', @resource.class.mime_type
  end

  test "should extract id from uri correctly" do
    id = @resource.send(:extract_id_from_uri, "documents/456")
    assert_equal 456, id
  end
end