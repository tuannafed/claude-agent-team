#!/usr/bin/env bash
set -euo pipefail

# Usage: ./add-to-existing.sh <project-path> --type <team-type>
# Adds agent team layer to an EXISTING project without overwriting code.

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/templates"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PROJECT_PATH=""
TEAM_TYPE="fullstack-web"

while [[ $# -gt 0 ]]; do
  case $1 in
    --type) TEAM_TYPE="$2"; shift 2 ;;
    -*) echo "Unknown flag: $1"; exit 1 ;;
    *) PROJECT_PATH="$1"; shift ;;
  esac
done

if [[ -z "$PROJECT_PATH" ]] || [[ ! -d "$PROJECT_PATH" ]]; then
  echo "Usage: $0 <existing-project-path> --type <team-type>"
  echo "Types: fullstack-web | api-only | ai-llm-app | chrome-extension"
  echo ""
  echo "Error: Project path must exist"
  exit 1
fi

PROJECT_NAME="$(basename "$PROJECT_PATH")"

echo "🔧 Adding agent team layer to existing project: $PROJECT_NAME"
echo "   Type: $TEAM_TYPE"
echo "   Path: $PROJECT_PATH"
echo ""
echo "⚠️  This will NOT modify existing source code."
echo "   It only adds: CLAUDE.md, .claude/conductor/, .claude/commands/"
echo ""
read -p "Continue? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || { echo "Aborted."; exit 0; }

# Delegate to init script — it already skips existing files
"$SCRIPT_DIR/init-new-project.sh" "$PROJECT_PATH" --type "$TEAM_TYPE" --name "$PROJECT_NAME"

echo ""
echo "📝 Generating tech-stack.md from existing codebase..."
echo "   (You'll need to fill this in based on your actual stack)"
echo ""

# Try to detect stack from common files
DETECTED=""

if [[ -f "$PROJECT_PATH/package.json" ]]; then
  if grep -q "next" "$PROJECT_PATH/package.json" 2>/dev/null; then
    DETECTED="$DETECTED Next.js"
  fi
  if grep -q "nestjs" "$PROJECT_PATH/package.json" 2>/dev/null; then
    DETECTED="$DETECTED NestJS"
  fi
  if grep -q "fastapi" "$PROJECT_PATH/package.json" 2>/dev/null; then
    DETECTED="$DETECTED FastAPI"
  fi
fi

if [[ -f "$PROJECT_PATH/pyproject.toml" ]] || [[ -f "$PROJECT_PATH/requirements.txt" ]]; then
  if grep -qi "fastapi" "$PROJECT_PATH/pyproject.toml" 2>/dev/null || \
     grep -qi "fastapi" "$PROJECT_PATH/requirements.txt" 2>/dev/null; then
    DETECTED="$DETECTED FastAPI(Python)"
  fi
fi

if [[ -n "$DETECTED" ]]; then
  echo "   Detected stack hints:$DETECTED"
  echo "   Please update .claude/conductor/tech-stack.md with actual details."
fi

echo ""
echo "✨ Agent team layer added to: $PROJECT_PATH"
echo ""
echo "Next steps:"
echo "  1. Open $PROJECT_PATH in Claude Code"
echo "  2. Update CLAUDE.md with project details"
echo "  3. Update .claude/conductor/product.md — describe what this project does"
echo "  4. Update .claude/conductor/tech-stack.md — document actual tech decisions"
echo "  5. Create your first track: /agent-team init \"feature to work on\""
