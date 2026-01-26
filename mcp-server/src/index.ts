#!/usr/bin/env bun
/**
 * MCP Server entry point for Ralph Specum.
 * Creates an MCP server with all Ralph tools and connects via stdio transport.
 */

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

import { MCPLogger } from "./lib/logger";
import { StateManager } from "./lib/state";
import { FileManager } from "./lib/files";
import { registerTools } from "./tools";

// Get version from package.json
import packageJson from "../package.json";

const SERVER_NAME = "ralph-specum";
const SERVER_VERSION = packageJson.version;

/**
 * Main entry point - starts the MCP server.
 */
async function main(): Promise<void> {
  const logger = new MCPLogger(SERVER_NAME);

  logger.info("Starting MCP server", {
    name: SERVER_NAME,
    version: SERVER_VERSION,
  });

  // Create server instance
  const server = new McpServer({
    name: SERVER_NAME,
    version: SERVER_VERSION,
  });

  // Initialize managers
  const fileManager = new FileManager(undefined, logger);
  const stateManager = new StateManager(logger);

  // Register all tools
  registerTools(server, fileManager, stateManager);

  logger.info("Tools registered", { count: 11 });

  // Create stdio transport
  const transport = new StdioServerTransport();

  // Connect server to transport
  await server.connect(transport);

  logger.info("Server connected and ready");
}

// Run the server
main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
