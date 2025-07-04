# MCP Development Guide

## MCP Architecture

### Tools vs Resources
- **Tools**: Implement callable functions that can modify state and return results
- **Resources**: Used for sharing data (read-only, subscription-based)
- Use `FastMcp::Tool` classes for interactive functionality

### Tool Structure
```ruby
class MyTool < FastMcp::Tool
  description "What this tool does"
  
  arguments do
    required(:param).filled(:string).description("Parameter description")
    optional(:option).filled(:integer).description("Optional parameter")
  end
  
  def call(param:, option: nil)
    # Implementation here
    result
  end
end
```

### Tool Registration
- Tools must be explicitly registered in the MCP configuration
- Use `server.register_tool(ToolClass)` in the Rails initializer
- Cannot rely on automatic discovery in all cases

### Argument Validation
- Uses Dry::Schema for argument validation
- Supports types: `:string`, `:integer`, `:float`, `:bool`, `:array`, `:hash`
- Validation happens automatically before `call` method execution

### Error Handling
- Raise standard Ruby exceptions, they're handled by the MCP framework
- Use descriptive error messages for better client experience
- ActiveRecord errors are automatically caught and converted

### Metadata Support
- Use `_meta` hash to include additional information in responses
- Useful for search results, pagination info, etc.
- Example: `_meta[:search_query] = query`

## Implementation Patterns

### Database Layer
- Standard Rails models with ActiveRecord
- Proper associations: `has_many :documents, dependent: :destroy`
- Validations: `validates :name, presence: true, uniqueness: true`
- Scopes for search: `scope :search, ->(query) { where("title LIKE ? OR content LIKE ?", "%#{query}%", "%#{query}%") }`

### MCP Tools Layer
- One tool per operation (single responsibility principle)
- Descriptive names: `ProjectCreateTool`, `DocumentSearchTool`
- Clear argument definitions with descriptions
- Consistent return formats

## MCP Protocol Specifics

### Initialization
```json
{
  "jsonrpc": "2.0",
  "method": "initialize", 
  "params": {
    "protocolVersion": "2024-11-05",
    "capabilities": {"roots": {"listChanged": true}, "sampling": {}}
  },
  "id": 1
}
```

### Tool Listing
```json
{
  "jsonrpc": "2.0",
  "method": "tools/list",
  "id": 2
}
```

### Tool Calling
```json
{
  "jsonrpc": "2.0",
  "method": "tools/call",
  "params": {
    "name": "ProjectCreateTool",
    "arguments": {"name": "Project Name", "description": "Description"}
  },
  "id": 3
}
```

## Rails Integration Notes

### Configuration
- Place MCP setup in `config/initializers/fast_mcp.rb`
- Use `FastMcp.mount_in_rails()` for Rails integration
- Default endpoint: `/mcp/messages`
- Supports HTTP transport with proper CORS handling

### File Structure
```
app/
  tools/           # MCP tool classes
  models/          # Standard Rails models
  resources/       # For MCP resources (if needed)
config/
  initializers/
    fast_mcp.rb    # MCP configuration
```

## Best Practices

1. **Tool Naming**: Use descriptive class names ending in "Tool"
2. **Single Purpose**: Each tool should do one thing well
3. **Consistent Returns**: Return structured data with consistent formats
4. **Error Messages**: Provide clear, actionable error messages
5. **Documentation**: Use detailed descriptions for tools and arguments
6. **Validation**: Let fast-mcp handle argument validation, focus on business logic validation

## Essential Considerations

- Tools are for actions, Resources for data sharing
- Register all tools explicitly in initializer
- Use proper Dry::Schema argument types
- Wrap database operations in proper error handling
- Test both model layer and MCP integration
- Test full flow from HTTP request to database

## General Development Learnings

• **Token efficiency matters** - Design APIs that minimize data transfer, especially when LLMs are the primary consumers

• **Keep registrations in sync** - When deleting components, check all configuration files that reference them

• **Test edge cases early** - Model validations and constraints often break assumptions in tests

• **Design for the consumer** - Consider how the end user (LLM) will actually use the interface, not just what's technically possible

• **Start simple, add complexity later** - Line-based editing beats full diff systems for most use cases

• **Error messages should be actionable** - Clear error handling improves the developer experience significantly

• **Single responsibility in tools** - One tool should do one thing well, even if it means more tools overall

• **Test the integration, not just the unit** - MCP tools need testing at the protocol level, not just the Ruby class level