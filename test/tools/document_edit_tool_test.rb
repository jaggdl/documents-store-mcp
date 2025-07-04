require "test_helper"

class DocumentEditToolTest < ActiveSupport::TestCase
  def setup
    @project = Project.create!(name: "Test Project", description: "Test project description")
    @document = Document.create!(
      title: "Test Document",
      content: "Line 1\nLine 2\nLine 3\nLine 4",
      project: @project
    )
    @tool = DocumentEditTool.new
  end

  test "should update document title only" do
    result = @tool.call(document_id: @document.id, title: "Updated Title")

    assert_equal "Updated Title", result[:title]
    assert_equal "Line 1\nLine 2\nLine 3\nLine 4", result[:content]

    @document.reload
    assert_equal "Updated Title", @document.title
  end

  test "should edit specific lines" do
    line_edits = {
      "2" => "Modified Line 2",
      "4" => "Modified Line 4"
    }

    result = @tool.call(document_id: @document.id, line_edits: line_edits)

    expected_content = "Line 1\nModified Line 2\nLine 3\nModified Line 4"
    assert_equal expected_content, result[:content]

    @document.reload
    assert_equal expected_content, @document.content
  end

  test "should prepend content" do
    result = @tool.call(document_id: @document.id, prepend_content: "New First Line")

    expected_content = "New First Line\nLine 1\nLine 2\nLine 3\nLine 4"
    assert_equal expected_content, result[:content]

    @document.reload
    assert_equal expected_content, @document.content
  end

  test "should append content" do
    result = @tool.call(document_id: @document.id, append_content: "New Last Line")

    expected_content = "Line 1\nLine 2\nLine 3\nLine 4\nNew Last Line"
    assert_equal expected_content, result[:content]

    @document.reload
    assert_equal expected_content, @document.content
  end

  test "should handle multiple operations together" do
    result = @tool.call(
      document_id: @document.id,
      title: "Updated Title",
      line_edits: { "2" => "Modified Line 2" },
      prepend_content: "New First Line",
      append_content: "New Last Line"
    )

    expected_content = "New First Line\nLine 1\nModified Line 2\nLine 3\nLine 4\nNew Last Line"
    assert_equal "Updated Title", result[:title]
    assert_equal expected_content, result[:content]

    @document.reload
    assert_equal "Updated Title", @document.title
    assert_equal expected_content, @document.content
  end

  test "should return complete document structure" do
    result = @tool.call(document_id: @document.id, title: "Updated Title")

    assert_equal @document.id, result[:id]
    assert_equal "Updated Title", result[:title]
    assert_equal @document.content, result[:content]
    assert_equal @project.id, result[:project][:id]
    assert_equal @project.name, result[:project][:name]
    assert_not_nil result[:created_at]
    assert_not_nil result[:updated_at]
  end

  test "should handle minimal document content" do
    @document.update!(content: ".")

    result = @tool.call(document_id: @document.id, append_content: "First line")

    assert_equal ".\nFirst line", result[:content]
  end

  test "should handle line edits on minimal document" do
    @document.update!(content: ".")

    line_edits = { "1" => "New line" }
    result = @tool.call(document_id: @document.id, line_edits: line_edits)

    assert_equal "New line", result[:content]
  end

  test "should raise error for non-existent document" do
    error = assert_raises(RuntimeError) do
      @tool.call(document_id: 99999, title: "Test")
    end

    assert_equal "Document not found", error.message
  end

  test "should raise error for invalid title" do
    error = assert_raises(RuntimeError) do
      @tool.call(document_id: @document.id, title: "")
    end

    assert_match "Validation failed", error.message
  end

  test "should do nothing when no edit parameters provided" do
    original_title = @document.title
    original_content = @document.content

    result = @tool.call(document_id: @document.id)

    assert_equal original_title, result[:title]
    assert_equal original_content, result[:content]

    @document.reload
    assert_equal original_title, @document.title
    assert_equal original_content, @document.content
  end

  test "should handle single line document" do
    @document.update!(content: "Single line")

    result = @tool.call(document_id: @document.id, line_edits: { "1" => "Modified single line" })

    assert_equal "Modified single line", result[:content]
  end

  test "should handle line numbers beyond document length" do
    line_edits = { "10" => "Line beyond end" }

    result = @tool.call(document_id: @document.id, line_edits: line_edits)

    lines = result[:content].split("\n")
    assert_equal 10, lines.length
    assert_equal "Line beyond end", lines[9]
    assert_equal "", lines[4]
  end
end
