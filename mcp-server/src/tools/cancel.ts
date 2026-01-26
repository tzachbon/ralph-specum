/**
 * ralph_cancel tool handler.
 * Cancels a spec by deleting .ralph-state.json and optionally the spec directory.
 */

import { z } from "zod";
import { FileManager } from "../lib/files";
import { StateManager } from "../lib/state";
import { MCPLogger } from "../lib/logger";
import {
  handleUnexpectedError,
  createErrorResponse,
  type ToolResult,
} from "../lib/errors";

/**
 * Zod schema for cancel tool input validation.
 */
export const CancelInputSchema = z.object({
  /** Name of the spec to cancel (uses current spec if not provided) */
  spec_name: z.string().optional(),
  /** Whether to delete the spec directory and all files (default: false) */
  delete_files: z.boolean().optional().default(false),
});

/**
 * Input type for the cancel tool.
 */
export type CancelInput = z.infer<typeof CancelInputSchema>;

/**
 * Handle the ralph_cancel tool.
 * Deletes .ralph-state.json and optionally the spec directory.
 */
export function handleCancel(
  fileManager: FileManager,
  stateManager: StateManager,
  input: CancelInput,
  logger?: MCPLogger
): ToolResult {
  try {
    // Validate input with Zod
    const parsed = CancelInputSchema.safeParse(input);
    if (!parsed.success) {
      return createErrorResponse(
        "VALIDATION_ERROR",
        parsed.error.errors[0]?.message ?? "Invalid input",
        logger
      );
    }

    const { spec_name, delete_files } = parsed.data;

    // Determine which spec to cancel
    const specName = spec_name ?? fileManager.getCurrentSpec();
    if (!specName) {
      return createErrorResponse(
        "MISSING_PREREQUISITES",
        "No spec specified and no current spec set. Use ralph_switch to select a spec or provide spec_name parameter.",
        logger
      );
    }

    // Check if spec exists
    if (!fileManager.specExists(specName)) {
      return createErrorResponse(
        "SPEC_NOT_FOUND",
        `Spec "${specName}" not found.`,
        logger
      );
    }

    const specDir = fileManager.getSpecDir(specName);
    const results: string[] = [];

    // Delete .ralph-state.json
    const stateDeleted = stateManager.delete(specDir);
    if (stateDeleted) {
      results.push("- Deleted .ralph-state.json");
    } else {
      results.push("- Warning: Failed to delete .ralph-state.json (may not exist)");
    }

    // Optionally delete the entire spec directory
    if (delete_files) {
      const specDeleted = fileManager.deleteSpec(specName);
      if (specDeleted) {
        results.push(`- Deleted spec directory: ${specName}/`);

        // Clear current spec if it was the deleted one
        const currentSpec = fileManager.getCurrentSpec();
        if (currentSpec === specName) {
          // Find another spec to set as current, or clear
          const remainingSpecs = fileManager.listSpecs();
          if (remainingSpecs.length > 0) {
            fileManager.setCurrentSpec(remainingSpecs[0]);
            results.push(`- Switched current spec to: ${remainingSpecs[0]}`);
          } else {
            // No need to clear .current-spec as specs dir may be empty
            results.push("- No remaining specs");
          }
        }
      } else {
        results.push(`- Error: Failed to delete spec directory`);
      }
    }

    // Build response
    const action = delete_files ? "cancelled and deleted" : "cancelled";
    const lines = [
      `Spec "${specName}" ${action}.`,
      "",
      "Actions taken:",
      ...results,
    ];

    if (!delete_files) {
      lines.push("");
      lines.push("Spec files preserved. Run again with delete_files: true to remove all files.");
    }

    return {
      content: [
        {
          type: "text",
          text: lines.join("\n"),
        },
      ],
    };
  } catch (error) {
    return handleUnexpectedError(error, "ralph_cancel", logger);
  }
}
