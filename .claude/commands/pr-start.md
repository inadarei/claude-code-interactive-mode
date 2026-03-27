Start tracking a PR chat log for ticket: $ARGUMENTS

Follow these steps to start tracking a PR chat log for the specified ticket:

1. Read the current tracking file at `pr-chats/.pr-tracking.json` if it exists, otherwise start with an empty JSON object `{}`.
2. CRITICAL: run `date -u +"%Y-%m-%dT%H:%M:%SZ"` in the shell and use the output as the current UTC timestamp. Do NOT guess or estimate the time — you must use the actual command output.
3. Find the current session's JSONL transcript file. Run this shell command to get the path:
   ```bash
   PROJECT_DIR="$(pwd)"; ENCODED="${PROJECT_DIR//\//-}"; ls -1t "$HOME/.claude/projects/$ENCODED"/*.jsonl 2>/dev/null | head -1
   ```
   Use the output as the session file path. If the command returns nothing, warn me but continue (the capture script will fall back to searching at capture time).
4. Add an entry to the JSON object with the ticket ID "$ARGUMENTS" as the key, and an object value containing:
   - `"start_ts"`: the UTC timestamp from step 2
   - `"session_file"`: the JSONL file path from step 3 (or null if not found)

   Example: `{"test-ticket-123": {"start_ts": "2026-03-26T21:08:21Z", "session_file": "/Users/me/.claude/projects/-Users-me-myproject/abc123.jsonl"}}`
5. Write the updated JSON to `pr-chats/.pr-tracking.json`.
6. Confirm to me that PR chat tracking has started for ticket "$ARGUMENTS" at the recorded timestamp.

Important: if "$ARGUMENTS" is empty, ask me to provide a ticket ID.
