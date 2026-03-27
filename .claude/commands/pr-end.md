End PR chat tracking for ticket: $ARGUMENTS

Follow these steps to end PR chat tracking for the specified ticket:

1. Read `pr-chats/.pr-tracking.json`. If it doesn't exist or doesn't contain ticket "$ARGUMENTS", tell me and stop.
2. Get the start timestamp for ticket "$ARGUMENTS". If it doesn't exist, tell me and stop.
3. Run the capture script to produce the **detailed** version:
   ```bash
   bash ~/.claude/scripts/pr-capture.sh "$ARGUMENTS"
   ```
   If the script doesn't exist, or is not executable, or fails in any other way - provide appropriate error message and abort the rest of the process. DO NOT try to recover, since it can damage the source files and destroy data.
   
   The script will find the current session's JSONL transcript, extract all entries from the start timestamp to now, format them as readable Markdown (human messages, assistant responses, and summarized tool calls), and save to `pr-chats/YY-MM-DD-HH-MM-<ticket-id>-detailed.md`.

   **Validation**: After the script runs, check its output for the number of messages captured. If it reports 0 messages or the detailed file is empty/missing, STOP and report the error to the user. Do NOT proceed to create full or summary files — the capture failed and needs debugging. Common causes: the start timestamp in `.pr-tracking.json` is in the future (was it recorded correctly via `date -u`?), or the session JSONL file wasn't found.
4. Read the detailed file the script produced. Using it as source, create two additional files:
   - **Full version** (`pr-chats/YY-MM-DD-HH-MM-<ticket-id>-brief.md`): A **mechanical filter** of the detailed file — copy it verbatim but remove all tool call sections (lines starting with `### 🔧 Tool:` through to the next `##` heading or end of file). Do NOT rephrase, summarize, or rewrite any content. The brief must contain the exact same human and assistant text as the detailed file.
   - **Summary version** (`pr-chats/YY-MM-DD-HH-MM-<ticket-id>-summary.md`): A concise, LLM-generated summary containing:
     - A short paragraph summarizing the conversation (what was discussed, what was the goal)
     - A bullet list of key decisions made and actions taken (files created/modified, architectural choices, etc.)
5. Remove the "$ARGUMENTS" entry from `pr-chats/.pr-tracking.json`.
6. Tell me the output file paths and a brief summary (number of messages captured).

Important: if "$ARGUMENTS" is empty, ask me to provide a ticket ID.
