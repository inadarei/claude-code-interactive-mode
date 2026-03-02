# Claude Code Setup

Example Claude Code setup in `$HOME/.claude` that delivers multiple useful features:

1. CLAUDE.md that instructs Claude to come up with careful plans before making ANY changes, and to always interview you, making sure you didn't forget to provide some requirements and it didn't misunderstand you
2. Implementation of a /document-context slash command, that helps initialize new and legacy code-bases with said CLAUDE.md as well as analyze the existing code-base (if any) to create meaningful, careful breadcrumbs, giving code full visibility into the code, making it helpful out of the gate
3. Example `settings.local.json` that allows Claude to make relatively safe changes (especially when combined with the above CLAUDE.md file) autonomously, so that it doesn't need you glued to the screen, while instructing it to still ask permission for more dangerous ones such as - checking anything into git or switching to sudo
