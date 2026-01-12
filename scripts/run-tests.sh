#!/bin/bash
# Run all tests for Ralph Specum

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}======================================${NC}"
echo -e "${YELLOW}  Ralph Specum Test Suite${NC}"
echo -e "${YELLOW}======================================${NC}"
echo

# Check for required tools
check_tool() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${RED}Error: $1 is not installed${NC}"
        echo "Please install $1 to run tests"
        exit 1
    fi
}

check_tool bats
check_tool jq

# Optional tools
if ! command -v yq &> /dev/null; then
    echo -e "${YELLOW}Warning: yq not installed. Some validation tests may be skipped.${NC}"
fi

if ! command -v shellcheck &> /dev/null; then
    echo -e "${YELLOW}Warning: shellcheck not installed. Lint checks will be skipped.${NC}"
fi

# Run linting if shellcheck is available
if command -v shellcheck &> /dev/null; then
    echo -e "${GREEN}Running ShellCheck...${NC}"
    find "$PROJECT_ROOT" -name "*.sh" -type f ! -path "*/node_modules/*" | xargs shellcheck --severity=warning || true
    echo
fi

# Validate JSON files
echo -e "${GREEN}Validating JSON files...${NC}"
for f in $(find "$PROJECT_ROOT" -name "*.json" -type f ! -path "*/node_modules/*" ! -path "*/.git/*"); do
    if jq empty "$f" 2>/dev/null; then
        echo "  ✓ $(basename "$f")"
    else
        echo -e "  ${RED}✗ $(basename "$f")${NC}"
        exit 1
    fi
done
echo

# Run BATS tests
run_bats_tests() {
    local test_type="$1"
    local test_path="$2"

    echo -e "${GREEN}Running $test_type tests...${NC}"
    if bats "$test_path"; then
        echo -e "${GREEN}✓ $test_type tests passed${NC}"
    else
        echo -e "${RED}✗ $test_type tests failed${NC}"
        return 1
    fi
    echo
}

# Run all test suites
FAILED=0

run_bats_tests "Unit" "$PROJECT_ROOT/tests/unit/*.bats" || FAILED=1
run_bats_tests "Validation" "$PROJECT_ROOT/tests/validation/*.bats" || FAILED=1
run_bats_tests "Flow" "$PROJECT_ROOT/tests/flows/*.bats" || FAILED=1
run_bats_tests "Contract" "$PROJECT_ROOT/tests/contracts/*.bats" || FAILED=1

echo -e "${YELLOW}======================================${NC}"
if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}  All tests passed!${NC}"
else
    echo -e "${RED}  Some tests failed${NC}"
fi
echo -e "${YELLOW}======================================${NC}"

exit $FAILED
