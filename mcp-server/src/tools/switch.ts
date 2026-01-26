/**
 * ralph_switch tool handler.
 * Switches to a different spec by updating .current-spec.
 */

import { z } from "zod";
import { FileManager } from "../lib/files";
import { MCPLogger } from "../lib/logger";
import {
  handleUnexpectedError,
  createErrorResponse,
  ErrorMessages,
  type ToolResult,
} from "../lib/errors";

/**
 * Zod schema for switch tool input validation.
 */
export const SwitchInputSchema = z.object({
  /** Name of the spec to switch to */
  name: z.string().min(1, "Spec name is required"),
});

/**
 * Input type for the switch tool.
 */
export type SwitchInput = z.infer<typeof SwitchInputSchema>;

/**
 * Handle the ralph_switch tool.
 * Validates spec exists and updates .current-spec.
 */
export function handleSwitch(
  fileManager: FileManager,
  input: SwitchInput,
  logger?: MCPLogger
): ToolResult {
  try {
    // Validate input with Zod
    const parsed = SwitchInputSchema.safeParse(input);
    if (!parsed.success) {
      return createErrorResponse(
        "VALIDATION_ERROR",
        parsed.error.errors[0]?.message ?? "Invalid input",
        logger
      );
    }

    const { name } = parsed.data;

    // Check if spec exists
    if (!fileManager.specExists(name)) {
      const specs = fileManager.listSpecs();
      const available = specs.length > 0 ? specs.join(", ") : "(none)";
      return createErrorResponse(
        "SPEC_NOT_FOUND",
        `Spec "${name}" not found. Available specs: ${available}`,
        logger
      );
    }

    // Check if already current
    const currentSpec = fileManager.getCurrentSpec();
    if (currentSpec === name) {
      return {
        content: [
          {
            type: "text",
            text: `Already on spec "${name}".`,
          },
        ],
      };
    }

    // Update .current-spec
    const success = fileManager.setCurrentSpec(name);
    if (!success) {
      return createErrorResponse(
        "FILE_OPERATION_ERROR",
        `Failed to switch to spec "${name}".`,
        logger
      );
    }

    // Build success response
    const previousSpec = currentSpec ?? "(none)";
    return {
      content: [
        {
          type: "text",
          text: `Switched to spec "${name}".\n\nPrevious: ${previousSpec}\nCurrent: ${name}\n\nRun ralph_status to see spec details.`,
        },
      ],
    };
  } catch (error) {
    return handleUnexpectedError(error, "ralph_switch", logger);
  }
}
