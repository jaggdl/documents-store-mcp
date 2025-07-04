# frozen_string_literal: true

# FastMcp - Model Context Protocol for Rails
# This initializer sets up the MCP middleware in your Rails application.
#
# In Rails applications, you can use:
# - ActionTool::Base as an alias for FastMcp::Tool
# - ActionResource::Base as an alias for FastMcp::Resource
#
# All your tools should inherit from ApplicationTool which already uses ActionTool::Base,
# and all your resources should inherit from ApplicationResource which uses ActionResource::Base.

# Mount the MCP middleware in your Rails application
# You can customize the options below to fit your needs.
require "fast_mcp"

FastMcp.mount_in_rails(
  Rails.application,
  name: "document-store-mcp",
  version: "1.0.0",
  path_prefix: "/mcp",
  messages_route: "messages",
  sse_route: "sse",
  allowed_origins: [ "*" ],
) do |server|
  Rails.application.config.after_initialize do
    # Register MCP tools (actions that modify state)
    server.register_tool(ProjectCreateTool)
    server.register_tool(ProjectUpdateTool)
    server.register_tool(ProjectDeleteTool)
    server.register_tool(DocumentCreateTool)
    server.register_tool(DocumentEditTool)
    server.register_tool(DocumentDeleteTool)

    # Register MCP resources (data sharing)
    server.register_resource(ProjectsResource)
    server.register_resource(ProjectResource)
    server.register_resource(DocumentsResource)
    server.register_resource(DocumentResource)
    server.register_resource(SearchResource)
  end
end
