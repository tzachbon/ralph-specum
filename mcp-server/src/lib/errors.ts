/**
 * Error handling utilities for MCP tools.
 * Provides standardized error responses and logging.
 */

import { MCPLogger } from "./logger";

/**
 * MCP TextContent response format.
 */
export interface TextContent {
  type: "text";
  text: string;
}

/**
 * MCP tool result format.
 */
export interface ToolResult {
  content: TextContent[];
  isError?: boolean;
}

/**
 * Standard error types for Ralph MCP tools.
 */
export type RalphErrorCode =
  | "SPEC_NOT_FOUND"
  | "INVALID_STATE"
  | "MISSING_PREREQUISITES"
  | "PHASE_MISMATCH"
  | "VALIDATION_ERROR"
  | "FILE_OPERATION_ERROR"
  | "INTERNAL_ERROR";

/**
 * Map error codes to user-friendly prefixes.
 */
const ERROR_PREFIXES: Record<RalphErrorCode, string> = {
  SPEC_NOT_FOUND: "Spec not found",
  INVALID_STATE: "Invalid state",
  MISSING_PREREQUISITES: "Missing prerequisites",
  PHASE_MISMATCH: "Phase mismatch",
  VALIDATION_ERROR: "Validation error",
  FILE_OPERATION_ERROR: "File operation failed",
  INTERNAL_ERROR: "Internal error",
};

/**
 * Create a standardized error response.
 * Never exposes stack traces to the client.
 */
export function createErrorResponse(
  code: RalphErrorCode,
  message: string,
  logger?: MCPLogger
): ToolResult {
  const prefix = ERROR_PREFIXES[code];
  const fullMessage = `Error: ${prefix} - ${message}`;

  // Log error to stderr if logger provided
  if (logger) {
    logger.error(fullMessage, { code });
  }

  return {
    content: [
      {
        type: "text",
        text: fullMessage,
      },
    ],
    isError: true,
  };
}

/**
 * Handle unexpected errors safely.
 * Logs the full error for debugging but returns a safe message to client.
 */
export function handleUnexpectedError(
  error: unknown,
  toolName: string,
  logger?: MCPLogger
): ToolResult {
  // Extract error message safely without exposing internals
  const errorMessage = error instanceof Error ? error.message : "Unknown error";

  // Log full error details to stderr for debugging
  if (logger) {
    logger.error(`Unexpected error in ${toolName}`, {
      error: errorMessage,
      tool: toolName,
      // Log stack trace to stderr for debugging but don't include in response
      stack: error instanceof Error ? error.stack : undefined,
    });
  }

  // Return safe message to client (no stack trace)
  return {
    content: [
      {
        type: "text",
        text: `Error: An unexpected error occurred in ${toolName}. Please try again or run ralph_status to check the current state.`,
      },
    ],
    isError: true,
  };
}

/**
 * Common error messages for reuse across tools.
 */
export const ErrorMessages = {
  noCurrentSpec: "No current spec set. Run ralph_start first or specify spec_name.",
  specNotFound: (specName: string) =>
    `Spec "${specName}" not found. Run ralph_status to see available specs.`,
  noStateFound: (specName: string) =>
    `No state found for spec "${specName}". Run ralph_start to initialize the spec.`,
  phaseMismatch: (specName: string, currentPhase: string, expectedPhase: string) =>
    `Spec "${specName}" is in "${currentPhase}" phase, not ${expectedPhase}. Run the appropriate tool for the current phase.`,
  missingPrerequisite: (specName: string, prerequisite: string) =>
    `${prerequisite} not found for spec "${specName}". Complete the previous phase first.`,
};
