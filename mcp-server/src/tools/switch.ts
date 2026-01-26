/**
 * ralph_switch tool handler.
 * Switches to a different spec by updating .current-spec.
 */

import { z } from "zod";
import { FileManager } from "../lib/files";

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
}

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
  input: SwitchInput
): ToolResult {
  // Validate input with Zod
  const parsed = SwitchInputSchema.safeParse(input);
  if (!parsed.success) {
    return {
      content: [
        {
          type: "text",
          text: `Error: ${parsed.error.errors[0]?.message ?? "Invalid input"}`,
        },
      ],
    };
  }

  const { name } = parsed.data;

  // Check if spec exists
  if (!fileManager.specExists(name)) {
    const specs = fileManager.listSpecs();
    const available = specs.length > 0 ? specs.join(", ") : "(none)";
    return {
      content: [
        {
          type: "text",
          text: `Error: Spec "${name}" not found.\n\nAvailable specs: ${available}`,
        },
      ],
    };
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
    return {
      content: [
        {
          type: "text",
          text: `Error: Failed to switch to spec "${name}".`,
        },
      ],
    };
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
}
