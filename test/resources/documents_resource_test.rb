require "test_helper"

class DocumentsResourceTest < ActiveSupport::TestCase
  def setup
    Project.destroy_all
    Document.destroy_all
    @project1 = Project.create!(name: "Test Project 1", description: "Test project 1 description")
    @project2 = Project.create!(name: "Test Project 2", description: "Test project 2 description")
    @document1 = Document.create!(title: "Doc 1", project: @project1)
    @document1.content = "Content 1"
    @document2 = Document.create!(title: "Doc 2", project: @project2)
    @document2.content = "Content 2"
    @resource = DocumentsResource.new
  end

  test "should return all documents with correct structure" do
    content = @resource.content
    documents = JSON.parse(content)

    assert_equal 2, documents.length

    document = documents.find { |d| d["id"] == @document1.id }
    assert_not_nil document
    assert_equal @document1.title, document["title"]
    assert_equal @document1.file_path, document["file_path"]
    assert_equal @project1.id, document["project"]["id"]
    assert_equal @project1.name, document["project"]["name"]
    assert_not_nil document["created_at"]
    assert_not_nil document["updated_at"]
  end

  test "should return empty array when no documents exist" do
    Document.destroy_all

    content = @resource.content
    documents = JSON.parse(content)

    assert_equal [], documents
  end

  test "should include project information for each document" do
    content = @resource.content
    documents = JSON.parse(content)

    documents.each do |document|
      assert_not_nil document["project"]
      assert_not_nil document["project"]["id"]
      assert_not_nil document["project"]["name"]
    end
  end

  test "should have correct resource metadata" do
    assert_equal "documents", @resource.class.uri
    assert_equal "Documents", @resource.class.resource_name
    assert_equal "All documents in the document store", @resource.class.description
    assert_equal "application/json", @resource.class.mime_type
  end
end
