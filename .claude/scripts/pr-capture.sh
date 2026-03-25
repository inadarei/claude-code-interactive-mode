#!/usr/bin/env bash
#
# pr-capture.sh — Extract a slice of the current Claude Code session transcript
# and format it as readable Markdown for attaching to PRs.
#
# Usage: bash .claude/scripts/pr-capture.sh <ticket-id>
#
# Requires: python3 (no pip packages needed)
# Reads:    pr-chats/.pr-tracking.json (for start timestamp)
# Finds:    Current session JSONL in ~/.claude/projects/
# Writes:   pr-chats/YY-MM-DD-HH-MM-<ticket-id>-detailed.md

set -euo pipefail

TICKET_ID="${1:?Usage: pr-capture.sh <ticket-id>}"
TRACKING_FILE="pr-chats/.pr-tracking.json"

# ── Preflight ──────────────────────────────────────────────────────────────────

if ! command -v python3 &>/dev/null; then
  echo "ERROR: python3 is required but not found." >&2
  exit 1
fi

if [[ ! -f "$TRACKING_FILE" ]]; then
  echo "ERROR: Tracking file not found: $TRACKING_FILE" >&2
  exit 1
fi

# ── Locate session transcript ──────────────────────────────────────────────────

PROJECT_DIR="$(pwd)"
ENCODED_PATH="${PROJECT_DIR//\//-}"
CLAUDE_PROJECTS_DIR="$HOME/.claude/projects"
SESSION_DIR="$CLAUDE_PROJECTS_DIR/$ENCODED_PATH"

# Portable "newest file" finder — works on both macOS (BSD) and Linux (GNU)
newest_by_pattern() {
  local search_dir="$1" pattern="$2"
  # Try ls -t: sorts by modification time, most recent first. Works everywhere.
  # shellcheck disable=SC2086
  ls -1t "$search_dir"/$pattern 2>/dev/null | head -1
}

if [[ ! -d "$SESSION_DIR" ]]; then
  echo "WARNING: No Claude session directory at: $SESSION_DIR" >&2
  echo "  Searching for alternatives..." >&2
  BASENAME="${PROJECT_DIR##*/}"
  CANDIDATE=""
  for dir in "$CLAUDE_PROJECTS_DIR"/*"${BASENAME}"*/; do
    [[ -d "$dir" ]] && CANDIDATE="$dir" && break
  done
  if [[ -n "$CANDIDATE" ]]; then
    SESSION_DIR="${CANDIDATE%/}"
    echo "  Using: $SESSION_DIR" >&2
  else
    echo "  No candidate found. Exiting." >&2
    exit 1
  fi
fi

# Find the most recently modified .jsonl file (current session)
SESSION_FILE=$(newest_by_pattern "$SESSION_DIR" "*.jsonl")

if [[ -z "$SESSION_FILE" || ! -f "$SESSION_FILE" ]]; then
  echo "ERROR: No JSONL session file found in: $SESSION_DIR" >&2
  exit 1
fi

echo "Session file: $SESSION_FILE" >&2

# ── Extract, format, and write ─────────────────────────────────────────────────

mkdir -p pr-chats

python3 - "$TICKET_ID" "$TRACKING_FILE" "$SESSION_FILE" "$PROJECT_DIR" << 'PYEOF'
import json
import sys
import os
from datetime import datetime, timezone

ticket_id = sys.argv[1]
tracking_file = sys.argv[2]
session_file = sys.argv[3]
project_dir = sys.argv[4]

# Read start timestamp
with open(tracking_file) as f:
    tracking = json.load(f)

if ticket_id not in tracking:
    print(f"ERROR: No tracking entry for ticket '{ticket_id}'", file=sys.stderr)
    sys.exit(1)

start_ts = tracking[ticket_id]

# Parse session and extract from start_ts onward
import re

output_parts = []
user_count = 0
assistant_count = 0
tool_count = 0
skip_next_user = False  # flag to skip expanded slash command template

def extract_slash_command(text):
    """Detect <command-name>/<command-args> tags and collapse to /command args."""
    cmd_match = re.search(r'<command-name>\s*(/[\w-]+)\s*</command-name>', text)
    if not cmd_match:
        return None
    cmd = cmd_match.group(1)
    args_match = re.search(r'<command-args>\s*(.*?)\s*</command-args>', text, re.DOTALL)
    args = args_match.group(1).strip() if args_match else ""
    return f"{cmd} {args}".strip() if args else cmd

with open(session_file) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            entry = json.loads(line)
        except json.JSONDecodeError:
            continue

        ts = entry.get("timestamp", "")
        if not ts or ts < start_ts:
            continue

        msg_type = entry.get("type")

        if msg_type == "user":
            content = entry.get("message", {}).get("content", "")
            # Gather all text parts
            if isinstance(content, str):
                text = content
            elif isinstance(content, list):
                parts = []
                for part in content:
                    pt = part.get("type", "")
                    if pt == "text":
                        parts.append(part["text"])
                text = "\n".join(parts)
            else:
                text = ""

            if not text:
                continue

            # Check if this is a slash command invocation
            slash_cmd = extract_slash_command(text)
            if slash_cmd:
                output_parts.append(f"## 👤 User\n\n`{slash_cmd}`\n")
                user_count += 1
                skip_next_user = True  # skip the expanded template that follows
                continue

            # Skip expanded slash command template
            if skip_next_user:
                skip_next_user = False
                continue

            output_parts.append(f"## 👤 User\n\n{text}\n")
            user_count += 1

        elif msg_type == "assistant":
            content = entry.get("message", {}).get("content", "")
            if isinstance(content, str):
                output_parts.append(f"## 🤖 Assistant\n\n{content}\n")
                assistant_count += 1
            elif isinstance(content, list):
                for part in content:
                    ptype = part.get("type", "")
                    if ptype == "text":
                        text = part.get("text", "").strip()
                        if text:
                            output_parts.append(f"## 🤖 Assistant\n\n{text}\n")
                            assistant_count += 1
                    elif ptype == "tool_use":
                        name = part.get("name", "unknown")
                        inp = part.get("input", {})
                        tool_count += 1

                        if name in ("Write", "write_to_file", "create_file",
                                    "MultiTool::CreateFile"):
                            fp = (inp.get("file_path") or inp.get("path")
                                  or "unknown")
                            output_parts.append(
                                f"### 🔧 Tool: `{name}`\n\n"
                                f"**File:** `{fp}`\n"
                            )
                        elif name in ("Edit", "str_replace_editor",
                                      "MultiTool::StrReplace"):
                            fp = (inp.get("file_path") or inp.get("path")
                                  or "unknown")
                            output_parts.append(
                                f"### 🔧 Tool: `{name}`\n\n"
                                f"**File:** `{fp}`\n"
                            )
                        elif name in ("Bash", "execute_command", "bash",
                                      "MultiTool::Bash"):
                            cmd = (inp.get("command") or inp.get("content")
                                   or "...")
                            if len(cmd) > 500:
                                cmd = cmd[:500] + "\n# ... (truncated)"
                            output_parts.append(
                                f"### 🔧 Tool: `{name}`\n\n"
                                f"```bash\n{cmd}\n```\n"
                            )
                        elif name in ("Read", "read_file",
                                      "MultiTool::ReadFile"):
                            fp = (inp.get("file_path") or inp.get("path")
                                  or "unknown")
                            output_parts.append(
                                f"### 🔧 Tool: `{name}`\n\n"
                                f"**File:** `{fp}`\n"
                            )
                        elif name in ("TodoWrite", "TodoRead"):
                            output_parts.append(
                                f"### 🔧 Tool: `{name}` — task list updated\n"
                            )
                        elif name in ("WebSearch", "WebFetch"):
                            q = (inp.get("query") or inp.get("url") or "...")
                            output_parts.append(
                                f"### 🔧 Tool: `{name}`\n\n"
                                f"**Query/URL:** {q}\n"
                            )
                        else:
                            output_parts.append(
                                f"### 🔧 Tool: `{name}`\n"
                            )

# Build final markdown
now_utc = datetime.now(timezone.utc).strftime("%y-%m-%d-%H-%M")
output_filename = f"pr-chats/{now_utc}-{ticket_id}-detailed.md"

with open(output_filename, "w") as out:
    out.write(f"# PR Chat Log: {ticket_id}\n\n")
    out.write(f"**Captured:** "
              f"{datetime.now(timezone.utc).strftime('%Y-%m-%d %H:%M UTC')}\n")
    out.write(f"**Started:** {start_ts}\n")
    out.write(f"**Project:** {project_dir}\n\n")
    out.write("---\n\n")
    out.write("\n".join(output_parts))

# Remove ticket from tracking
del tracking[ticket_id]
with open(tracking_file, "w") as f:
    json.dump(tracking, f, indent=2)

# Summary to stderr
print(f"✅ Captured: {output_filename}", file=sys.stderr)
print(f"   {user_count} user messages, {assistant_count} assistant responses, "
      f"{tool_count} tool calls", file=sys.stderr)

# Output filename to stdout for the calling command
print(output_filename)
PYEOF
