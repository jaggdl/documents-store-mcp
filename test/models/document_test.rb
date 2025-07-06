require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  def setup
    @project = Project.create!(name: "Test Project", description: "A test project")
  end

  test "should create document with valid attributes" do
    document = @project.documents.create(title: "Test Document")
    document.content = "Test content"
    assert document.valid?
    assert document.persisted?
    assert_equal "Test content", document.content
  end

  test "should not create document without title" do
    document = @project.documents.new
    document.content = "Test content"
    assert_not document.valid?
    assert_includes document.errors[:title], "can't be blank"
  end


  test "should belong to project" do
    document = @project.documents.create!(title: "Test Document")
    document.content = "Test content"
    assert_equal @project, document.project
  end

  test "should search documents by title" do
    doc1 = @project.documents.create!(title: "Ruby Programming")
    doc1.content = "About Ruby"
    doc2 = @project.documents.create!(title: "Python Guide")
    doc2.content = "About Python"

    results = Document.search("Ruby")
    assert_includes results, doc1
    assert_not_includes results, doc2
  end

  test "should search documents by content" do
    doc1 = @project.documents.create!(title: "Language Guide")
    doc1.content = "Ruby is a dynamic language"
    doc2 = @project.documents.create!(title: "Framework Guide")
    doc2.content = "Rails is a web framework"

    results = Document.search("dynamic")
    assert_includes results, doc1
    assert_not_includes results, doc2
  end
end
