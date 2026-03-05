#!/usr/bin/env bash
set -euo pipefail

# Usage: ./upgrade-project.sh [<project-path>] [--dry-run] [--type <team-type>]
#
# Syncs the latest agent team templates into an existing project.
# Safe to run anytime — only overwrites agent/command/skill files, never user content.
#
# What gets UPDATED (overwritten with latest templates):
#   .claude/agents/*.md       — agent definitions (prompts improve over time)
#   .claude/commands/*.md     — slash commands (new subcommands, fixes)
#   .claude/skills/*.md       — skill files (MANIFEST.md + all present skills)
#   .claude/settings.json     — hooks config
#
# What is NEVER touched:
#   CLAUDE.md                        — user's project context
#   .claude/conductor/product.md     — user's product vision
#   .claude/conductor/tech-stack.md  — user's tech decisions
#   .claude/conductor/knowledge.md   — accumulated lessons
#   .claude/conductor/tracks/        — track history
#   Any source code

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/templates"
PROJECT_PATH=""
DRY_RUN=false
TEAM_TYPE=""

# ── Parse arguments ────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case $1 in
    --dry-run)     DRY_RUN=true; shift ;;
    --type)        TEAM_TYPE="$2"; shift 2 ;;
    -*) echo "Unknown flag: $1"; echo "Usage: $(basename "${BASH_SOURCE[0]}") [<project-path>] [--type <team-type>] [--dry-run]"; exit 1 ;;
    *) PROJECT_PATH="$1"; shift ;;
  esac
done

# ── Banner ─────────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════════╗"
echo "║  Claude Agent Team — Upgrade Project     ║"
echo "╚══════════════════════════════════════════╝"
echo ""

# ── Project path ──────────────────────────────────────────────────────────────
if [[ -z "$PROJECT_PATH" ]]; then
  DEFAULT_PATH="$(pwd)"
  printf "Project path [%s]: " "$DEFAULT_PATH"
  read -r input_path
  PROJECT_PATH="${input_path:-$DEFAULT_PATH}"
fi

PROJECT_PATH="${PROJECT_PATH/#\~/$HOME}"

if [[ ! -d "$PROJECT_PATH" ]]; then
  echo "Error: Directory not found: $PROJECT_PATH"
  exit 1
fi

PROJECT_NAME="$(basename "$PROJECT_PATH")"
DOTCLAUDE="$PROJECT_PATH/.claude"

if [[ ! -d "$DOTCLAUDE" ]]; then
  echo "Error: No .claude/ directory found in $PROJECT_PATH"
  echo "       Run init-new-project.sh first."
  exit 1
fi

echo "  Project : $PROJECT_NAME"
echo "  Path    : $PROJECT_PATH"
[[ "$DRY_RUN" == true ]] && echo "  Mode    : dry-run (no files changed)"
echo ""

# ── Auto-detect team type if not specified ─────────────────────────────────────
if [[ -z "$TEAM_TYPE" ]]; then
  # Detect from existing agents
  if [[ -f "$DOTCLAUDE/agents/chrome-ext.md" ]]; then
    TEAM_TYPE="chrome-extension"
  elif [[ -f "$DOTCLAUDE/agents/ai-engineer.md" ]]; then
    TEAM_TYPE="ai-llm-app"
  elif [[ -f "$DOTCLAUDE/agents/api-designer.md" ]]; then
    TEAM_TYPE="api-only"
  elif [[ -f "$DOTCLAUDE/agents/frontend-nextjs.md" ]]; then
    TEAM_TYPE="fullstack-web"
  else
    TEAM_TYPE="fullstack-web"
  fi
  echo "  Auto-detected type: $TEAM_TYPE (use --type to override)"
  echo ""
fi

# ── Determine agent set for this team type ─────────────────────────────────────
case "$TEAM_TYPE" in
  fullstack-web)    AGENTS="ba-agent ba-agent-bug db-engineer backend-nestjs backend-fastapi frontend-nextjs integrator code-reviewer" ;;
  api-only)         AGENTS="ba-agent ba-agent-bug db-engineer backend-nestjs backend-fastapi api-designer code-reviewer" ;;
  ai-llm-app)       AGENTS="ba-agent ba-agent-bug backend-nestjs backend-fastapi ai-engineer frontend-nextjs code-reviewer" ;;
  chrome-extension) AGENTS="ba-agent ba-agent-bug frontend-nextjs chrome-ext code-reviewer" ;;
  *)                AGENTS="ba-agent ba-agent-bug code-reviewer" ;;
esac

# ── Helper: copy_if_template_exists ───────────────────────────────────────────
UPDATED=0
SKIPPED=0

update_file() {
  local src="$1"
  local dest="$2"
  local label="$3"

  if [[ ! -f "$src" ]]; then
    echo "   ⚠️  Template not found: $label (skipped)"
    (( SKIPPED++ )) || true
    return
  fi

  if [[ "$DRY_RUN" == true ]]; then
    echo "   would update: $label"
    (( UPDATED++ )) || true
    return
  fi

  cp "$src" "$dest"
  echo "   ✅ $label"
  (( UPDATED++ )) || true
}

# ── 1. Update agents ───────────────────────────────────────────────────────────
echo "Updating agents..."
mkdir -p "$DOTCLAUDE/agents"

for agent in $AGENTS; do
  # Also include any optional domain agents already present
  :
done

# Update agents that EXIST in the project (don't add new ones unless they're in AGENTS)
for agent in $AGENTS; do
  update_file \
    "$TEMPLATE_DIR/.claude/agents/$agent.md" \
    "$DOTCLAUDE/agents/$agent.md" \
    ".claude/agents/$agent.md"
done

# Also update any domain agents already present in the project
for extra in chrome-ext ai-engineer api-designer; do
  dest="$DOTCLAUDE/agents/$extra.md"
  src="$TEMPLATE_DIR/.claude/agents/$extra.md"
  if [[ -f "$dest" ]] && [[ ! " $AGENTS " =~ " $extra " ]]; then
    update_file "$src" "$dest" ".claude/agents/$extra.md"
  fi
done

# ── 2. Update commands ─────────────────────────────────────────────────────────
echo ""
echo "Updating commands..."
mkdir -p "$DOTCLAUDE/commands"

for cmd in agent-team checkpoint learn; do
  update_file \
    "$TEMPLATE_DIR/commands/$cmd.md" \
    "$DOTCLAUDE/commands/$cmd.md" \
    ".claude/commands/$cmd.md"
done

# ── 3. Update skills (only those already present in the project) ───────────────
echo ""
echo "Updating skills..."
mkdir -p "$DOTCLAUDE/skills"

# Always update MANIFEST
update_file \
  "$TEMPLATE_DIR/.claude/skills/MANIFEST.md" \
  "$DOTCLAUDE/skills/MANIFEST.md" \
  ".claude/skills/MANIFEST.md"

# Update all skill files that already exist in the project
if [[ -d "$DOTCLAUDE/skills" ]]; then
  while IFS= read -r -d '' existing_skill; do
    skill_name="$(basename "$existing_skill")"
    [[ "$skill_name" == "MANIFEST.md" ]] && continue
    src="$TEMPLATE_DIR/.claude/skills/$skill_name"
    if [[ -f "$src" ]]; then
      update_file "$src" "$existing_skill" ".claude/skills/$skill_name"
    fi
  done < <(find "$DOTCLAUDE/skills" -maxdepth 1 -name "*.md" -print0 2>/dev/null)
fi

# ── 4. Update settings.json ────────────────────────────────────────────────────
echo ""
echo "Updating settings..."
if [[ -f "$DOTCLAUDE/settings.json" ]]; then
  update_file \
    "$TEMPLATE_DIR/.claude/settings.json" \
    "$DOTCLAUDE/settings.json" \
    ".claude/settings.json"
else
  echo "   ⏭️  .claude/settings.json (not present, skipped)"
fi

# ── Summary ────────────────────────────────────────────────────────────────────
echo ""
if [[ "$DRY_RUN" == true ]]; then
  echo "🔍 Dry run complete — $UPDATED file(s) would be updated."
else
  echo "✨ Upgrade complete! $UPDATED file(s) updated in: $PROJECT_PATH"
fi
echo ""
echo "Not touched (your content is safe):"
echo "  CLAUDE.md"
echo "  .claude/conductor/product.md"
echo "  .claude/conductor/tech-stack.md"
echo "  .claude/conductor/knowledge.md"
echo "  .claude/conductor/tracks/"
echo ""
