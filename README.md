# Document Store MCP Server

A Model Context Protocol (MCP) server for managing projects and documents, built with Rails. This server provides structured document storage and retrieval capabilities through the MCP protocol, making it ideal for AI assistants and other applications that need to organize and access text content.

## Features

### Project Management
- Create, read, update, and delete projects
- List all projects with document counts
- Organize documents within projects

### Document Management
- Create markdown documents within projects
- Advanced editing capabilities (line-based edits, append/prepend)
- Full-text search across document titles and content
- Complete CRUD operations on documents

### MCP Integration
- 11 MCP tools for comprehensive document management
- HTTP transport support for remote access
- Proper error handling and validation

## Available MCP Tools

### Project Tools
- `ProjectCreateTool` - Create new projects
- `ProjectListTool` - List all projects
- `ProjectReadTool` - Read project details
- `ProjectUpdateTool` - Update project information
- `ProjectDeleteTool` - Delete projects

### Document Tools
- `DocumentCreateTool` - Create new documents
- `DocumentListTool` - List documents (optionally by project)
- `DocumentReadTool` - Read document content
- `DocumentEditTool` - Edit documents with advanced line-based editing
- `DocumentDeleteTool` - Delete documents
- `DocumentSearchTool` - Search documents by title or content

## Prerequisites

- Ruby 3.2+ 
- Rails 8.0+
- SQLite3

## Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd document-store-mcp
```

2. Install dependencies:
```bash
bundle install
```

3. Set up the database:
```bash
rails db:create
rails db:migrate
```

4. (Optional) Seed with sample data:
```bash
rails db:seed
```

## Running the Server

### Development Mode
```bash
rails server -p 8347
```

The MCP server will be available at `http://localhost:8347/mcp/messages`

### Production Mode
```bash
RAILS_ENV=production rails server -p 8347
```

## Setting Up with Claude Code

### Local Development Server

1. Start the Rails server on port 8347:
```bash
rails server -p 8347
```

2. Add the MCP server to Claude Code:
```bash
claude mcp add document-store --transport http http://localhost:8347/mcp/sse
```

### Remote Server

If you've deployed the server to a remote host:

```bash
claude mcp add document-store --transport http https://your-server.com/mcp
```

### Important Notes

- The Rails server must be running on port 8347 for the MCP client to connect properly
- If you see "Endpoint not found" errors, ensure the server is running and accessible on the correct port
- The MCP endpoint is available at `/mcp/messages` on the Rails server

## Verifying the Connection

After adding the server to Claude Code, verify it's working:

1. Check MCP server status:
```bash
/mcp
```

2. Test the connection by asking Claude to:
- "List all projects"
- "Create a new project called 'Test Project'"
- "Create a document in the project"

## Configuration

### Environment Variables

- `RAILS_ENV` - Set to `production` for production deployment
- `SECRET_KEY_BASE` - Required for production mode
- `DATABASE_URL` - Database connection string (optional, defaults to SQLite)

### MCP Configuration

The MCP server is configured in `config/initializers/fast_mcp.rb`:

- **Name**: `document-store-mcp`
- **Version**: `1.0.0`
- **Path**: `/mcp`
- **Transport**: HTTP

## Usage Examples

Once connected to Claude Code, you can:

```
> Create a new project called "My Documentation" with description "Project documentation and notes"

> List all projects

> Create a document titled "Getting Started" in project 1 with some markdown content

> Search for documents containing "API"

> Edit document 1 to add a new section at the end

> List all documents in project 1
```

## API Endpoints

- `POST /mcp/messages` - Main MCP communication endpoint
- `GET /mcp/sse` - Server-sent events endpoint (if using SSE transport)

## Development

### Running Tests
```bash
rails test
```

### Code Style
```bash
rubocop
```

### Security Scan
```bash
brakeman
```

## Project Structure

```
app/
├── models/
│   ├── project.rb          # Project model
│   └── document.rb         # Document model
├── tools/                  # MCP tool implementations
│   ├── project_*_tool.rb   # Project management tools
│   └── document_*_tool.rb  # Document management tools
└── ...
config/
├── initializers/
│   └── fast_mcp.rb         # MCP server configuration
└── ...
```

## Troubleshooting

### Common Issues

1. **Connection refused**: Ensure the Rails server is running on port 8347 and accessible
2. **Endpoint not found (HTTP 404)**: The server is running but not on the expected port - check that Rails is started with `-p 8347`
3. **Tool not found**: Check that all tools are properly registered in `config/initializers/fast_mcp.rb`
4. **Database errors**: Run `rails db:migrate` to ensure database schema is up to date
5. **Port conflicts**: If port 8347 is already in use, stop the conflicting process or use a different port

### Debug Mode

Enable debug logging by setting:
```bash
RAILS_LOG_LEVEL=debug rails server
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Run the test suite
6. Submit a pull request

## License

This project is licensed under the MIT License.
