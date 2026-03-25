End PR chat tracking for ticket: $ARGUMENTS

Follow these steps to end PR chat tracking for the specified ticket:

1. Read `pr-chats/.pr-tracking.json`. If it doesn't exist or doesn't contain ticket "$ARGUMENTS", tell me and stop.
2. Get the start timestamp for ticket "$ARGUMENTS". If it doesn't exist, tell me and stop.
3. Run the capture script to produce the **detailed** version:
   ```bash
   bash .claude/scripts/pr-capture.sh "$ARGUMENTS"
   ```
   The script will find the current session's JSONL transcript, extract all entries from the start timestamp to now, format them as readable Markdown (human messages, assistant responses, and summarized tool calls), and save to `pr-chats/YY-MM-DD-HH-MM-<ticket-id>-detailed.md`.
4. Read the detailed file the script produced. Using it as source, create two additional files:
   - **Brief version** (`pr-chats/YY-MM-DD-HH-MM-<ticket-id>-brief.md`): Same as detailed but with all tool call sections (lines starting with `### 🔧 Tool:`) removed.
   - **Summary version** (`pr-chats/YY-MM-DD-HH-MM-<ticket-id>-summary.md`): A concise, LLM-generated summary containing:
     - A short paragraph summarizing the conversation (what was discussed, what was the goal)
     - A bullet list of key decisions made and actions taken (files created/modified, architectural choices, etc.)
5. Remove the "$ARGUMENTS" entry from `pr-chats/.pr-tracking.json`.
6. Tell me the output file paths and a brief summary (number of messages captured).

Important: if "$ARGUMENTS" is empty, ask me to provide a ticket ID.
