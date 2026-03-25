# PR Chat Log Capture

Capture Claude Code conversation logs and attach them to pull requests.

## Setup

Ensure the following files are in your project:

```
.claude/
  commands/
    pr-start.md     # /pr-start slash command
    pr-end.md        # /pr-end slash command
  scripts/
    pr-capture.sh    # extraction + formatting script
pr-chats/
  .gitkeep           # output directory
```

**Dependency:** `python3` must be available (no pip packages needed).

## Usage

### 1. Start tracking

When you begin work on a ticket, run in Claude Code:

```
/pr-start TICKET-123
```

This records the current timestamp. Everything from this point forward will be
captured.

### 2. Work normally

Have your conversation with Claude Code as usual — coding, debugging, discussing
architecture, whatever.

### 3. End tracking and capture

When you're ready to create the PR:

```
/pr-end TICKET-123
```

This extracts the conversation from the start marker to now and produces three
Markdown files:

```
pr-chats/YY-MM-DD-HH-MM-TICKET-123-detailed.md
pr-chats/YY-MM-DD-HH-MM-TICKET-123-brief.md
pr-chats/YY-MM-DD-HH-MM-TICKET-123-summary.md
```

### 4. Commit with your PR

```bash
git add pr-chats/
git commit -m "Add Claude chat log for TICKET-123"
```

## Output Format

Three versions are produced:

- **Detailed** — Full conversation with user messages (👤), assistant responses
  (🤖), and summarized tool calls (🔧: file paths for reads/writes/edits,
  commands for bash, queries for web search). Full tool output is omitted for
  readability.
- **Brief** — Same as detailed but with all tool call sections removed.
- **Summary** — An LLM-generated summary of the conversation: a short paragraph
  describing what was discussed, followed by a bullet list of key decisions made
  and actions taken.

Slash commands (`/pr-start`, `/pr-end`, etc.) are automatically collapsed to
their short form — the expanded command template is not included in the output.

## Notes

- Tracking state is stored in `pr-chats/.pr-tracking.json` (add to `.gitignore`
  if you prefer)
- You can track multiple tickets simultaneously
- The script uses the most recently modified `.jsonl` session file — if you
  `--resume` mid-tracking, ensure you're in the same session
- The `pr-chats/` directory can be added to `.gitignore` if you prefer linking
  logs externally rather than committing them
