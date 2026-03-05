#!/usr/bin/env bash
set -euo pipefail

# Usage: ./remove-from-project.sh [<project-path>] [--keep-tracks] [--dry-run]
# Removes agent team files from a project.
#
# What gets removed:
#   .claude/conductor/     — all agent team metadata (tracks, specs, knowledge)
#   .claude/commands/      — agent-team, checkpoint, learn commands
#   .claude/agents/        — all agent .md files
#   .claude/skills/        — all skill .md files + MANIFEST.md
#   .claude/settings.json  — hooks config
#   CLAUDE.md              — project context file (prompts for confirmation)
#
# What is NEVER removed:
#   .claude/ itself (may contain user's own files)
#   Any source code files (src/, app/, etc.)
#
# Flags:
#   --keep-tracks   Keep .claude/conductor/tracks/ (preserve track history)
#   --dry-run       Show what would be removed without deleting anything

SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"
PROJECT_PATH=""
KEEP_TRACKS=false
DRY_RUN=false

# ── Parse arguments ────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --keep-tracks) KEEP_TRACKS=true; shift ;;
    --dry-run)     DRY_RUN=true; shift ;;
    -*) echo "Unknown flag: $1"; echo "Usage: $SCRIPT_NAME [<project-path>] [--keep-tracks] [--dry-run]"; exit 1 ;;
    *) PROJECT_PATH="$1"; shift ;;
  esac
done

# ── Banner ─────────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  Claude Agent Team — Remove from Project ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── Project path ──────────────────────────────────────────────────────────────
if [[ -z "$PROJECT_PATH" ]]; then
  DEFAULT_PATH="$(pwd)"
  printf "Project path [%s]: " "$DEFAULT_PATH"
  read -r input_path
  PROJECT_PATH="${input_path:-$DEFAULT_PATH}"
fi

# Expand ~
PROJECT_PATH="${PROJECT_PATH/#\~/$HOME}"

if [[ ! -d "$PROJECT_PATH" ]]; then
  echo "Error: Directory not found: $PROJECT_PATH"
  exit 1
fi

PROJECT_NAME="$(basename "$PROJECT_PATH")"

echo "  Project : $PROJECT_NAME"
echo "  Path    : $PROJECT_PATH"
[[ "$KEEP_TRACKS" == true ]] && echo "  Mode    : keep track history"
[[ "$DRY_RUN" == true ]]     && echo "  Mode    : dry-run (no files deleted)"
echo ""

# ── Build removal list ─────────────────────────────────────────────────────────
DOTCLAUDE="$PROJECT_PATH/.claude"

declare -a TO_REMOVE=()
declare -a TO_REMOVE_LABELS=()

# .claude/conductor/ (entire dir, or just excluding tracks/)
if [[ -d "$DOTCLAUDE/conductor" ]]; then
  if [[ "$KEEP_TRACKS" == true ]]; then
    # Remove individual files but keep tracks/
    for f in product.md tech-stack.md workflow.md knowledge.md tracks.md team-config.md checkpoints.log; do
      fp="$DOTCLAUDE/conductor/$f"
      if [[ -f "$fp" ]]; then
        TO_REMOVE+=("$fp")
        TO_REMOVE_LABELS+=(".claude/conductor/$f")
      fi
    done
    # Remove notes/ if exists
    if [[ -d "$DOTCLAUDE/conductor/notes" ]]; then
      TO_REMOVE+=("$DOTCLAUDE/conductor/notes")
      TO_REMOVE_LABELS+=(".claude/conductor/notes/")
    fi
  else
    TO_REMOVE+=("$DOTCLAUDE/conductor")
    TO_REMOVE_LABELS+=(".claude/conductor/")
  fi
fi

# .claude/commands/ — only remove agent team commands, not user's own commands
for cmd in agent-team checkpoint learn; do
  fp="$DOTCLAUDE/commands/$cmd.md"
  if [[ -f "$fp" ]]; then
    TO_REMOVE+=("$fp")
    TO_REMOVE_LABELS+=(".claude/commands/$cmd.md")
  fi
done

# .claude/agents/ — only .md files (agent definitions)
if [[ -d "$DOTCLAUDE/agents" ]]; then
  while IFS= read -r -d '' f; do
    rel=".claude/agents/$(basename "$f")"
    TO_REMOVE+=("$f")
    TO_REMOVE_LABELS+=("$rel")
  done < <(find "$DOTCLAUDE/agents" -maxdepth 1 -name "*.md" -print0 2>/dev/null)
fi

# .claude/skills/ — entire directory
if [[ -d "$DOTCLAUDE/skills" ]]; then
  TO_REMOVE+=("$DOTCLAUDE/skills")
  TO_REMOVE_LABELS+=(".claude/skills/")
fi

# .claude/settings.json — hooks config
if [[ -f "$DOTCLAUDE/settings.json" ]]; then
  TO_REMOVE+=("$DOTCLAUDE/settings.json")
  TO_REMOVE_LABELS+=(".claude/settings.json")
fi

# ── Preview ────────────────────────────────────────────────────────────────────
if [[ ${#TO_REMOVE[@]} -eq 0 ]] && [[ ! -f "$PROJECT_PATH/CLAUDE.md" ]]; then
  echo "ℹ️  No agent team files found in: $PROJECT_PATH"
  echo "   (Nothing to remove)"
  exit 0
fi

echo "The following will be removed:"
echo ""
for label in "${TO_REMOVE_LABELS[@]}"; do
  echo "   🗑️  $label"
done

# Handle CLAUDE.md separately — ask user
REMOVE_CLAUDE_MD=false
if [[ -f "$PROJECT_PATH/CLAUDE.md" ]]; then
  echo ""
  printf "   Remove CLAUDE.md? (may contain your customizations) [y/N]: "
  read -r ans
  [[ "$ans" =~ ^[Yy]$ ]] && REMOVE_CLAUDE_MD=true
fi

echo ""

# ── Dry run output ─────────────────────────────────────────────────────────────
if [[ "$DRY_RUN" == true ]]; then
  echo "🔍 Dry run — no files were deleted."
  [[ "$REMOVE_CLAUDE_MD" == true ]] && echo "   Would also remove: CLAUDE.md"
  exit 0
fi

# ── Confirm ────────────────────────────────────────────────────────────────────
printf "Proceed with removal? [y/N]: "
read -r confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

echo ""
echo "🗑️  Removing agent team files..."
echo ""

# ── Execute removal ────────────────────────────────────────────────────────────
REMOVED=0
FAILED=0

for i in "${!TO_REMOVE[@]}"; do
  target="${TO_REMOVE[$i]}"
  label="${TO_REMOVE_LABELS[$i]}"

  if [[ -d "$target" ]]; then
    rm -rf "$target" && echo "   ✅ $label" && (( REMOVED++ )) || { echo "   ❌ Failed: $label"; (( FAILED++ )); }
  elif [[ -f "$target" ]]; then
    rm -f "$target"  && echo "   ✅ $label" && (( REMOVED++ )) || { echo "   ❌ Failed: $label"; (( FAILED++ )); }
  fi
done

# Remove CLAUDE.md if confirmed
if [[ "$REMOVE_CLAUDE_MD" == true ]]; then
  rm -f "$PROJECT_PATH/CLAUDE.md" && echo "   ✅ CLAUDE.md" && (( REMOVED++ )) || { echo "   ❌ Failed: CLAUDE.md"; (( FAILED++ )); }
fi

# Clean up empty .claude/commands/ and .claude/agents/ dirs if nothing else in them
for dir in "$DOTCLAUDE/commands" "$DOTCLAUDE/agents"; do
  if [[ -d "$dir" ]] && [[ -z "$(ls -A "$dir" 2>/dev/null)" ]]; then
    rmdir "$dir" && echo "   ✅ $(basename "$dir")/ (empty, removed)"
  fi
done

echo ""
if [[ $FAILED -eq 0 ]]; then
  echo "✨ Done! Removed $REMOVED item(s) from: $PROJECT_PATH"
  [[ "$KEEP_TRACKS" == true ]] && echo "   Track history preserved in: .claude/conductor/tracks/"
else
  echo "⚠️  Completed with $FAILED error(s). $REMOVED item(s) removed."
fi
echo ""
