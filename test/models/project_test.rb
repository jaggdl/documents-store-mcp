require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "should create project with valid attributes" do
    project = Project.create(name: "Test Project", description: "A test project")
    assert project.valid?
    assert project.persisted?
  end
  
  test "should not create project without name" do
    project = Project.new(description: "A test project")
    assert_not project.valid?
    assert_includes project.errors[:name], "can't be blank"
  end
  
  test "should not create project without description" do
    project = Project.new(name: "Test Project")
    assert_not project.valid?
    assert_includes project.errors[:description], "can't be blank"
  end
  
  test "should not create project with duplicate name" do
    Project.create!(name: "Test Project", description: "A test project")
    duplicate = Project.new(name: "Test Project", description: "Another test project")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:name], "has already been taken"
  end
  
  test "should destroy associated documents when project is destroyed" do
    project = Project.create!(name: "Test Project", description: "A test project")
    document = project.documents.create!(title: "Test Document", content: "Test content")
    
    assert_difference 'Document.count', -1 do
      project.destroy
    end
  end
end
