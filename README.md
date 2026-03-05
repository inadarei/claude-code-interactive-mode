# What This Is

"Claude Code Only Works on New Code" or "Claude Code Only Works If You Vibe Alone"

You’ve likely heard, or experienced, it before: developers getting amazing results when asking agents like Claude to build something from scratch, but having comparatively less success using it for "actual work", you know, that 10-plus-years-old Java monolith everything actually runs on. Similarly, you start a new project and everything is great, but you collaborator or team-mate checks the same code out of github, runs new Claude session - and everything is not as smooth.

It doesn't have to be this way.

The core issue is context. When you build something new, Claude is there from the first prompt. It understands every design decision because it made them. But when you drop Claude into a legacy codebase, that contextual knowledge is gone. Even worse, if you try to "fix" this by shoehorning your entire architecture into a single, top-level CLAUDE.md file, you’ll likely hit a wall, once that file exceeds ~200 lines, instruction reliability craters.

The solution? Don't document your codebase all in one place!

Instead, leave a trail of "breadcrumb" CLAUDE.md files throughout your directory structure, create carefully thought-out skills and commands. By scoping context files to specific modules or packages, they are only loaded when Claude is actually working in that section of the code.

Best part - if you try to do this yourself, it can be very labor-intensive. But you can have Claude do most of it, and just review-tweak!

This repository has a command to achieve exactly that. It also has a very valuable top-level CLAUDE.md that makes sure your Claude sessions always follow explain-plan-question-only-change-code-when-given-permission loop, without having to constantly jump in and out of /plan mode. 

And, it also has sensible settings.local.json so once you get the plan you can leave your Claude working without having to "babysit" it.

# Repo Structure

Example Claude Code setup in `$HOME/.claude` that delivers multiple useful features:

1. CLAUDE.md that instructs Claude to come up with careful plans before making ANY changes, and to always interview you, making sure you didn't forget to provide some requirements and it didn't misunderstand you
2. Implementation of a [/document-context](https://github.com/inadarei/claude-code-interactive-mode/blob/main/.claude/commands/document-context) slash command that creates careful map of your code for future Claude Sessions, and can help your collaborators, if you check the code into git
3. Implementation of a [/instrument-project](https://github.com/inadarei/claude-code-interactive-mode/blob/main/.claude/commands/instrument-project) slash command that helps initialize new and legacy code-bases with said CLAUDE.md as well as analyze the existing code-base (if any) to create meaningful, careful breadcrumbs, giving code full visibility into the code, making it helpful out of the gate
4. Example `settings.local.json` that allows Claude to make relatively safe changes (especially when combined with the above CLAUDE.md file) autonomously, so that it doesn't need you glued to the screen, while instructing it to still ask permission for more dangerous ones such as - checking anything into git or switching to sudo
