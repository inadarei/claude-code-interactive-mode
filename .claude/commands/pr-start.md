Start tracking a PR chat log for ticket: $ARGUMENTS

Follow these steps to start tracking a PR chat log for the specified ticket:

1. Read the current tracking file at `pr-chats/.pr-tracking.json` if it exists, otherwise start with an empty JSON object `{}`.
2. Record the current UTC timestamp in ISO 8601 format.
3. Add an entry to the JSON object with the ticket ID "$ARGUMENTS" as the key, and the timestamp as the value.
4. Write the updated JSON to `pr-chats/.pr-tracking.json`.
5. Confirm to me that PR chat tracking has started for ticket "$ARGUMENTS" at the recorded timestamp.

Important: if "$ARGUMENTS" is empty, ask me to provide a ticket ID.
