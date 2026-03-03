# Initialize this project with my standard Claude configuration files.

1. Run `mkdir -p .claude{commands,hooks}` to create the `.claude/commands` and `.claude/hooks` directories if they doesn't exist
2. Copy `~/.claude/CLAUDE.md` to `./CLAUDE.md` — skip if `./CLAUDE.md` already exists
3. Copy `~/.claude/hooks/check-context-doc.sh` to `.claude/hooks/check-context-doc.sh` - skip if it already exists
4. Copy `~/.claude/settings.local.json` to `./.claude/settings.json` — skip if `./.claude/settings.json` already exists
5. Add `~/.claude/.gitignore` file with a single entry of `settings.local.json`
6. Report each file: whether it was copied or skipped (already exists)
