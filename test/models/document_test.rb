require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  def setup
    @project = Project.create!(name: "Test Project", description: "A test project")
  end

  test "should create document with valid attributes" do
    document = @project.documents.create(title: "Test Document", content: "Test content")
    assert document.valid?
    assert document.persisted?
  end

  test "should not create document without title" do
    document = @project.documents.new(content: "Test content")
    assert_not document.valid?
    assert_includes document.errors[:title], "can't be blank"
  end

  test "should not create document without content" do
    document = @project.documents.new(title: "Test Document")
    assert_not document.valid?
    assert_includes document.errors[:content], "can't be blank"
  end

  test "should belong to project" do
    document = @project.documents.create!(title: "Test Document", content: "Test content")
    assert_equal @project, document.project
  end

  test "should search documents by title" do
    doc1 = @project.documents.create!(title: "Ruby Programming", content: "About Ruby")
    doc2 = @project.documents.create!(title: "Python Guide", content: "About Python")

    results = Document.search("Ruby")
    assert_includes results, doc1
    assert_not_includes results, doc2
  end

  test "should search documents by content" do
    doc1 = @project.documents.create!(title: "Language Guide", content: "Ruby is a dynamic language")
    doc2 = @project.documents.create!(title: "Framework Guide", content: "Rails is a web framework")

    results = Document.search("dynamic")
    assert_includes results, doc1
    assert_not_includes results, doc2
  end
end
