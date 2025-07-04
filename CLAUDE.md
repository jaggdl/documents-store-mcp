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

### Architecture & Design
• **Understand the domain model first** - Know what's for reading vs writing before choosing implementation patterns
• **Follow framework conventions** - Don't fight the intended usage patterns (Tools for actions, Resources for data)
• **Design for the consumer** - Consider how the end user (human or AI) will actually interact with the interface
• **Token efficiency matters** - Design APIs that minimize data transfer, especially when LLMs are the primary consumers
• **Single responsibility in tools** - One tool should do one thing well, even if it means more tools overall

### Testing Strategy  
• **Test framework syntax matters** - Don't assume testing patterns transfer between frameworks (RSpec vs Minitest)
• **Isolate test state early** - Add proper setup/teardown before tests get complex and interdependent
• **Run tests incrementally** - Validate each change rather than debugging large broken changesets
• **Test edge cases early** - Model validations and constraints often break assumptions in tests
• **Test the integration, not just the unit** - MCP tools need testing at the protocol level, not just the Ruby class level

### Development Process
• **Use the right tool for the job** - Task tool for searches/exploration, direct tools for known operations
• **Let error messages guide you** - Systematic debugging beats guessing when you have clear failure messages
• **Keep related files organized** - Parallel directory structures make navigation and maintenance easier
• **Keep registrations in sync** - When deleting components, check all configuration files that reference them
• **Start simple, add complexity later** - Line-based editing beats full diff systems for most use cases

### Code Patterns
• **Build in flexibility for different contexts** - Methods may need to work in production and test environments differently
• **Provide sensible fallbacks** - `param || fallback1 || fallback2` patterns handle edge cases gracefully
• **Consolidate configuration** - Keep related registrations/setup in one discoverable place
• **Error messages should be actionable** - Clear error handling improves the developer experience significantly

### Meta-Learning
• **Reflect on what broke and why** - The specific failure modes teach you what to watch for next time
• **Document the "why" not just the "what"** - Understanding intent helps with future changes

## Key Learnings for Future Tasks

### Architecture & Design
• **Business logic belongs in models** - Keep view-specific logic out of helpers/views for better reusability
• **Design for the consumer** - Consider how end users will interact with the interface when making architectural decisions
• **Progressive enhancement works** - Build basic functionality first, then add enhancements in logical layers

### Development Process
• **Use TodoWrite for complex tasks** - Break down multi-step work and track progress systematically
• **Test each layer before adding complexity** - Validate MVC structure before adding features like markdown rendering
• **Follow framework conventions** - Rails patterns (nested resources, controller organization) make code predictable

### Tool Integration
• **Understand tool capabilities before implementing** - Research what frameworks provide (like Tailwind Typography) before writing custom solutions
• **Security-first for user content** - Always sanitize and validate user-generated content, even in internal tools
• **Leverage existing solutions** - Use established libraries (Redcarpet, Tailwind Typography) rather than building custom implementations

### Code Quality
• **Separation of concerns pays off** - Model methods can be reused across multiple views and contexts
• **Responsive design from the start** - Build with mobile-first, responsive patterns using framework utilities
• **Plan for reusability** - Methods like `content_preview(length)` with flexible parameters serve multiple use cases

### Meta-Learning
• **Reflect on architectural decisions** - Good early choices (model-first design) make later enhancements cleaner
• **Document the "why" not just the "what"** - Understanding intent helps with future modifications