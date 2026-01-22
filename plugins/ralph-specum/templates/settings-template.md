---
enabled: true
default_max_iterations: 5
auto_commit_spec: true
quick_mode_default: false
---

# Ralph Specum Configuration

This file configures Ralph Specum plugin behavior for this project.

## Settings

### enabled
Enable/disable the plugin entirely. Set to `false` to disable all hooks and commands.

### default_max_iterations
Default maximum retries per failed task before blocking (default: 5).

### auto_commit_spec
Whether to automatically commit spec files after generation (default: true).

### quick_mode_default
Whether to run in quick mode by default when no flag provided (default: false).

## Usage

Create this file at `.claude/ralph-specum.local.md` in your project root to customize plugin behavior.

## Example

```yaml
---
enabled: true
default_max_iterations: 3
auto_commit_spec: false
quick_mode_default: true
---

# Ralph Specum Configuration

Custom settings for this project.
```
