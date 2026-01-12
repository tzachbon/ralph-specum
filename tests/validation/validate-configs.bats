#!/usr/bin/env bats
# Validation tests for JSON configuration files

PROJECT_ROOT="${BATS_TEST_DIRNAME}/../.."

# ============================================================================
# JSON Syntax Validation
# ============================================================================

@test "plugin.json is valid JSON" {
    run jq empty "$PROJECT_ROOT/.claude-plugin/plugin.json"
    [ "$status" -eq 0 ]
}

@test "marketplace.json is valid JSON" {
    run jq empty "$PROJECT_ROOT/.claude-plugin/marketplace.json"
    [ "$status" -eq 0 ]
}

@test "hooks.json is valid JSON" {
    run jq empty "$PROJECT_ROOT/hooks/hooks.json"
    [ "$status" -eq 0 ]
}

@test "settings.json is valid JSON" {
    run jq empty "$PROJECT_ROOT/.claude/settings.json"
    [ "$status" -eq 0 ]
}

# ============================================================================
# plugin.json Schema Validation
# ============================================================================

@test "plugin.json has required 'name' field" {
    name=$(jq -r '.name' "$PROJECT_ROOT/.claude-plugin/plugin.json")
    [ -n "$name" ]
    [ "$name" != "null" ]
}

@test "plugin.json has required 'version' field" {
    version=$(jq -r '.version' "$PROJECT_ROOT/.claude-plugin/plugin.json")
    [ -n "$version" ]
    [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "plugin.json has required 'description' field" {
    description=$(jq -r '.description' "$PROJECT_ROOT/.claude-plugin/plugin.json")
    [ -n "$description" ]
    [ "$description" != "null" ]
    [ ${#description} -ge 10 ]
}

@test "plugin.json has author with name" {
    author_name=$(jq -r '.author.name' "$PROJECT_ROOT/.claude-plugin/plugin.json")
    [ -n "$author_name" ]
    [ "$author_name" != "null" ]
}

@test "plugin.json name follows convention (lowercase, hyphens)" {
    name=$(jq -r '.name' "$PROJECT_ROOT/.claude-plugin/plugin.json")
    [[ "$name" =~ ^[a-z0-9-]+$ ]]
}

# ============================================================================
# marketplace.json Schema Validation
# ============================================================================

@test "marketplace.json has required 'name' field" {
    name=$(jq -r '.name' "$PROJECT_ROOT/.claude-plugin/marketplace.json")
    [ -n "$name" ]
    [ "$name" != "null" ]
}

@test "marketplace.json has required 'owner' field" {
    owner=$(jq -r '.owner.name' "$PROJECT_ROOT/.claude-plugin/marketplace.json")
    [ -n "$owner" ]
    [ "$owner" != "null" ]
}

@test "marketplace.json has at least one plugin" {
    count=$(jq '.plugins | length' "$PROJECT_ROOT/.claude-plugin/marketplace.json")
    [ "$count" -ge 1 ]
}

@test "marketplace.json plugins have required fields" {
    # Check first plugin has all required fields
    plugin=$(jq '.plugins[0]' "$PROJECT_ROOT/.claude-plugin/marketplace.json")

    name=$(echo "$plugin" | jq -r '.name')
    [ -n "$name" ] && [ "$name" != "null" ]

    description=$(echo "$plugin" | jq -r '.description')
    [ -n "$description" ] && [ "$description" != "null" ]

    version=$(echo "$plugin" | jq -r '.version')
    [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]

    source=$(echo "$plugin" | jq -r '.source')
    [ -n "$source" ] && [ "$source" != "null" ]
}

@test "marketplace.json plugin version matches plugin.json version" {
    plugin_version=$(jq -r '.version' "$PROJECT_ROOT/.claude-plugin/plugin.json")
    marketplace_version=$(jq -r '.plugins[0].version' "$PROJECT_ROOT/.claude-plugin/marketplace.json")
    [ "$plugin_version" = "$marketplace_version" ]
}

# ============================================================================
# hooks.json Schema Validation
# ============================================================================

@test "hooks.json has 'hooks' object" {
    hooks=$(jq '.hooks' "$PROJECT_ROOT/hooks/hooks.json")
    [ "$hooks" != "null" ]
}

@test "hooks.json Stop hook exists" {
    stop_hooks=$(jq '.hooks.Stop' "$PROJECT_ROOT/hooks/hooks.json")
    [ "$stop_hooks" != "null" ]
}

@test "hooks.json Stop hook has valid structure" {
    # Check first Stop hook matcher
    matcher=$(jq -r '.hooks.Stop[0].matcher' "$PROJECT_ROOT/hooks/hooks.json")
    [ -n "$matcher" ]

    # Check hooks array exists
    hooks_array=$(jq '.hooks.Stop[0].hooks' "$PROJECT_ROOT/hooks/hooks.json")
    [ "$hooks_array" != "null" ]
}

@test "hooks.json command type hooks have command field" {
    # Find all command type hooks and verify they have command field
    commands=$(jq -r '.hooks.Stop[].hooks[] | select(.type == "command") | .command' "$PROJECT_ROOT/hooks/hooks.json")
    [ -n "$commands" ]
}

@test "hooks.json references existing script" {
    # Extract script path from hook command
    command=$(jq -r '.hooks.Stop[0].hooks[0].command' "$PROJECT_ROOT/hooks/hooks.json")

    # The command references ${CLAUDE_PLUGIN_ROOT}, so check relative path
    if [[ "$command" == *"stop-handler.sh"* ]]; then
        [ -f "$PROJECT_ROOT/hooks/scripts/stop-handler.sh" ]
    fi
}

# ============================================================================
# Cross-file Consistency
# ============================================================================

@test "plugin name is consistent across configs" {
    plugin_name=$(jq -r '.name' "$PROJECT_ROOT/.claude-plugin/plugin.json")
    marketplace_name=$(jq -r '.plugins[0].name' "$PROJECT_ROOT/.claude-plugin/marketplace.json")
    [ "$plugin_name" = "$marketplace_name" ]
}

@test "author name is consistent across configs" {
    plugin_author=$(jq -r '.author.name' "$PROJECT_ROOT/.claude-plugin/plugin.json")
    marketplace_author=$(jq -r '.plugins[0].author.name' "$PROJECT_ROOT/.claude-plugin/marketplace.json")
    [ "$plugin_author" = "$marketplace_author" ]
}
