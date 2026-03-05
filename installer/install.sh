#!/bin/sh
# Claude Code configuration installer
# Usage: curl -fsSL https://raw.githubusercontent.com/inadarei/claude-code-interactive-mode/main/installer/install.sh | sh

REPO_RAW="https://raw.githubusercontent.com/inadarei/claude-code-interactive-mode/main"
DEST="$HOME/.claude"

# Files to install (relative to repo root, under .claude/)
FILES="
CLAUDE.md
settings.local.json
commands/document-context.md
commands/instrument-project.md
hooks/check-context-doc.sh
"

# Files that need executable bit set after download
EXEC_FILES="
hooks/check-context-doc.sh
"

# ---------------------------------------------------------------------------

download() {
    url="$1"
    dest="$2"
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL "$url" -o "$dest"
    elif command -v wget >/dev/null 2>&1; then
        wget -q -O "$dest" "$url"
    else
        printf 'Error: neither curl nor wget found. Please install one and retry.\n' >&2
        exit 1
    fi
}

is_exec_file() {
    rel="$1"
    for f in $EXEC_FILES; do
        if [ "$rel" = "$f" ]; then
            return 0
        fi
    done
    return 1
}

installed=""
skipped=""
failed=""

for rel in $FILES; do
    dest_file="$DEST/$rel"
    src_url="$REPO_RAW/.claude/$rel"

    if [ -e "$dest_file" ]; then
        skipped="$skipped
  $rel"
    else
        mkdir -p "$(dirname "$dest_file")"
        if download "$src_url" "$dest_file"; then
            if is_exec_file "$rel"; then
                chmod +x "$dest_file"
            fi
            installed="$installed
  $rel"
        else
            failed="$failed
  $rel"
        fi
    fi
done

printf '\n=== Claude Config Installer ===\n'

if [ -n "$installed" ]; then
    printf '\nInstalled:%s\n' "$installed"
fi

if [ -n "$skipped" ]; then
    printf '\nSkipped (already exist — not modified, please update/merge manually):%s\n' "$skipped"
fi

if [ -n "$failed" ]; then
    printf '\nFailed to download:%s\n' "$failed"
fi

printf '\nDone.\n'
