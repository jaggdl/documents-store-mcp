require "test_helper"

class SearchResourceTest < ActiveSupport::TestCase
  def setup
    Project.destroy_all
    Document.destroy_all
    @project = Project.create!(name: "Test Project", description: "Test project description")
    @document1 = Document.create!(title: "Ruby Guide", content: "Learn Ruby programming", project: @project)
    @document2 = Document.create!(title: "Rails Tutorial", content: "Build web apps with Ruby on Rails", project: @project)
    @document3 = Document.create!(title: "JavaScript Basics", content: "Frontend development with JS", project: @project)
    @resource = SearchResource.new
  end

  test "should return search results with correct structure" do
    content = @resource.content("search/Ruby")
    result = JSON.parse(content)
    
    assert_equal "Ruby", result["search_query"]
    assert_equal 2, result["results_count"]
    assert_equal 2, result["results"].length
    
    document = result["results"].first
    assert_not_nil document["id"]
    assert_not_nil document["title"]
    assert_not_nil document["content"]
    assert_not_nil document["project"]
    assert_not_nil document["project"]["id"]
    assert_not_nil document["project"]["name"]
    assert_not_nil document["created_at"]
    assert_not_nil document["updated_at"]
  end

  test "should return empty results for non-matching query" do
    content = @resource.content("search/Python")
    result = JSON.parse(content)
    
    assert_equal "Python", result["search_query"]
    assert_equal 0, result["results_count"]
    assert_equal [], result["results"]
  end

  test "should handle empty query" do
    content = @resource.content("search/")
    result = JSON.parse(content)
    
    assert_equal [], result
  end

  test "should handle URL encoded query" do
    content = @resource.content("search/Ruby%20programming")
    result = JSON.parse(content)
    
    assert_equal "Ruby programming", result["search_query"]
    assert result["results_count"] > 0
  end

  test "should search in both title and content" do
    content = @resource.content("search/web")
    result = JSON.parse(content)
    
    assert_equal "web", result["search_query"]
    assert_equal 1, result["results_count"]
    assert_equal @document2.title, result["results"].first["title"]
  end

  test "should have correct resource metadata" do
    assert_equal 'search/{query}', @resource.class.uri
    assert_equal 'Search', @resource.class.resource_name
    assert_equal 'Search documents by query', @resource.class.description
    assert_equal 'application/json', @resource.class.mime_type
  end

  test "should extract query from uri correctly" do
    query = @resource.send(:extract_query_from_uri, "search/test%20query")
    assert_equal "test query", query
  end
end