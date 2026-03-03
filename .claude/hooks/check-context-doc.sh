#!/usr/bin/env bash
# PostToolUse hook: when Claude edits/writes a file in a directory that has a CLAUDE.md,
# remind Claude to check whether that CLAUDE.md needs updating.

set -euo pipefail

input=$(cat)

tool_name=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null)

if [[ "$tool_name" != "Edit" && "$tool_name" != "Write" ]]; then
    exit 0
fi

file_path=$(echo "$input" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)

if [[ -z "$file_path" ]]; then
    exit 0
fi

dir=$(dirname "$file_path")
context_doc="$dir/CLAUDE.md"

if [[ -f "$context_doc" ]]; then
    echo "Note: $context_doc exists in the same directory as the file you just modified. Check whether it needs to be updated to reflect your changes."
fi

exit 0
