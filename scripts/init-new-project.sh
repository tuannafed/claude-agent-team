#!/usr/bin/env bash
set -euo pipefail

# Usage: ./init-new-project.sh <project-path> --type <team-type> [--name <project-name>] [--chrome-ext] [--ai]
# Types: fullstack-web | api-only | ai-llm-app | chrome-extension
# Flags: --chrome-ext  also copies chrome-extension domain skills
#        --ai          also copies AI/RAG domain skills

TEMPLATE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/templates"

# Parse arguments
PROJECT_PATH=""
TEAM_TYPE="fullstack-web"
PROJECT_NAME=""
INCLUDE_CHROME_EXT=false
INCLUDE_AI=false

while [[ $# -gt 0 ]]; do
  case $1 in
    --type) TEAM_TYPE="$2"; shift 2 ;;
    --name) PROJECT_NAME="$2"; shift 2 ;;
    --chrome-ext) INCLUDE_CHROME_EXT=true; shift ;;
    --ai) INCLUDE_AI=true; shift ;;
    -*) echo "Unknown flag: $1"; exit 1 ;;
    *) PROJECT_PATH="$1"; shift ;;
  esac
done

if [[ -z "$PROJECT_PATH" ]]; then
  echo "Usage: $0 <project-path> --type <team-type> [--name <project-name>]"
  echo "Types: fullstack-web | api-only | ai-llm-app | chrome-extension"
  exit 1
fi

# Derive project name from path if not provided
if [[ -z "$PROJECT_NAME" ]]; then
  PROJECT_NAME="$(basename "$PROJECT_PATH")"
fi

echo "🚀 Initializing agent team for: $PROJECT_NAME"
echo "   Type: $TEAM_TYPE"
echo "   Path: $PROJECT_PATH"
echo ""

# Create directory if it doesn't exist
mkdir -p "$PROJECT_PATH"

# 1. Create conductor/ structure
echo "📁 Creating conductor/ structure..."
mkdir -p "$PROJECT_PATH/conductor/tracks"

# Copy conductor templates
for template in product.md tech-stack.md workflow.md knowledge.md tracks.md; do
  if [[ ! -f "$PROJECT_PATH/conductor/$template" ]]; then
    cp "$TEMPLATE_DIR/conductor/$template" "$PROJECT_PATH/conductor/$template"
    # Replace placeholder
    sed -i.bak "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$PROJECT_PATH/conductor/$template"
    rm "$PROJECT_PATH/conductor/$template.bak"
    echo "   ✅ conductor/$template"
  else
    echo "   ⏭️  conductor/$template (already exists, skipped)"
  fi
done

# 2. Create CLAUDE.md
echo ""
echo "📄 Creating CLAUDE.md..."
if [[ ! -f "$PROJECT_PATH/CLAUDE.md" ]]; then
  # Determine agent pipeline based on team type
  case "$TEAM_TYPE" in
    fullstack-web)    PIPELINE="BA → DB Engineer → Backend → Frontend → Integrator → Reviewer" ;;
    api-only)         PIPELINE="BA → DB Engineer → Backend → API Designer → Reviewer" ;;
    ai-llm-app)       PIPELINE="BA → Backend → AI Engineer → Frontend → Reviewer" ;;
    chrome-extension) PIPELINE="BA → Frontend → Chrome Ext Dev → Reviewer" ;;
    *) PIPELINE="BA → Reviewer" ;;
  esac

  cp "$TEMPLATE_DIR/CLAUDE.md.template" "$PROJECT_PATH/CLAUDE.md"
  sed -i.bak "s/{{PROJECT_NAME}}/$PROJECT_NAME/g" "$PROJECT_PATH/CLAUDE.md"
  sed -i.bak "s/{{TEAM_TYPE}}/$TEAM_TYPE/g" "$PROJECT_PATH/CLAUDE.md"
  sed -i.bak "s|{{AGENT_PIPELINE}}|$PIPELINE|g" "$PROJECT_PATH/CLAUDE.md"
  sed -i.bak "s/{{PROJECT_DESCRIPTION}}/[Fill in: what does this project do?]/g" "$PROJECT_PATH/CLAUDE.md"
  sed -i.bak "s/{{FRONTEND_STACK}}/[e.g. Next.js 15 + React 19]/g" "$PROJECT_PATH/CLAUDE.md"
  sed -i.bak "s/{{BACKEND_STACK}}/[e.g. NestJS or FastAPI]/g" "$PROJECT_PATH/CLAUDE.md"
  sed -i.bak "s/{{DATABASE}}/[e.g. PostgreSQL]/g" "$PROJECT_PATH/CLAUDE.md"
  sed -i.bak "s/{{AUTH_SOLUTION}}/[e.g. JWT + refresh tokens]/g" "$PROJECT_PATH/CLAUDE.md"
  sed -i.bak "s/{{DEPLOYMENT}}/[e.g. AWS ECS + Vercel]/g" "$PROJECT_PATH/CLAUDE.md"
  sed -i.bak "s/{{CURRENT_PHASE}}/planning/g" "$PROJECT_PATH/CLAUDE.md"
  sed -i.bak "s/{{CONSTRAINT_1}}/[Fill in key constraints]/g" "$PROJECT_PATH/CLAUDE.md"
  rm "$PROJECT_PATH/CLAUDE.md.bak"
  echo "   ✅ CLAUDE.md"
else
  echo "   ⏭️  CLAUDE.md (already exists, skipped)"
fi

# 3. Create .claude/commands/ and .claude/agents/
echo ""
echo "🔧 Setting up .claude/ (commands + agents)..."
mkdir -p "$PROJECT_PATH/.claude/commands"
mkdir -p "$PROJECT_PATH/.claude/agents"

# Copy commands
for cmd in agent-team checkpoint learn; do
  if [[ ! -f "$PROJECT_PATH/.claude/commands/$cmd.md" ]]; then
    cp "$TEMPLATE_DIR/commands/$cmd.md" "$PROJECT_PATH/.claude/commands/$cmd.md"
    echo "   ✅ .claude/commands/$cmd.md"
  else
    echo "   ⏭️  .claude/commands/$cmd.md (already exists)"
  fi
done

# Copy settings.json (hooks)
if [[ ! -f "$PROJECT_PATH/.claude/settings.json" ]]; then
  cp "$TEMPLATE_DIR/.claude/settings.json" "$PROJECT_PATH/.claude/settings.json"
  echo "   ✅ .claude/settings.json (hooks)"
else
  echo "   ⏭️  .claude/settings.json (already exists)"
fi

# Copy skills
mkdir -p "$PROJECT_PATH/.claude/skills"

# Core skills — always copied
CORE_SKILLS="api-contract security-baseline testing-strategy git-workflow"

# Framework skills — copied for all standard project types
FRAMEWORK_SKILLS="typescript-patterns database-patterns nextjs-patterns nestjs-patterns react-query-patterns fastapi-patterns"

# Quality skills — always copied
QUALITY_SKILLS="error-handling-patterns form-validation-patterns"

ALL_SKILLS="$CORE_SKILLS $FRAMEWORK_SKILLS $QUALITY_SKILLS"

# Domain skills — copied only when relevant flag is set
if [[ "$INCLUDE_CHROME_EXT" == true ]]; then
  ALL_SKILLS="$ALL_SKILLS chrome-extension-mv3"
fi
if [[ "$INCLUDE_AI" == true ]]; then
  ALL_SKILLS="$ALL_SKILLS prompt-engineering rag-architecture"
fi

cp "$TEMPLATE_DIR/.claude/skills/MANIFEST.md" "$PROJECT_PATH/.claude/skills/MANIFEST.md"
echo "   ✅ .claude/skills/MANIFEST.md"

for skill in $ALL_SKILLS; do
  SRC="$TEMPLATE_DIR/.claude/skills/$skill.md"
  DEST="$PROJECT_PATH/.claude/skills/$skill.md"
  if [[ -f "$SRC" ]]; then
    if [[ ! -f "$DEST" ]]; then
      cp "$SRC" "$DEST"
      echo "   ✅ .claude/skills/$skill.md"
    else
      echo "   ⏭️  .claude/skills/$skill.md (already exists)"
    fi
  else
    echo "   ⚠️  Skill template not found: $skill.md (skipped)"
  fi
done

# Copy native agent files (YAML frontmatter format — auto-detected by Claude Code)
# Select agents based on team type
case "$TEAM_TYPE" in
  fullstack-web)
    AGENTS="ba-agent db-engineer backend-nestjs backend-fastapi frontend-nextjs integrator code-reviewer"
    ;;
  api-only)
    AGENTS="ba-agent db-engineer backend-nestjs backend-fastapi api-designer code-reviewer"
    ;;
  ai-llm-app)
    AGENTS="ba-agent backend-nestjs backend-fastapi ai-engineer frontend-nextjs code-reviewer"
    ;;
  chrome-extension)
    AGENTS="ba-agent frontend-nextjs chrome-ext code-reviewer"
    ;;
  *)
    AGENTS="ba-agent code-reviewer"
    ;;
esac

for agent in $AGENTS; do
  SRC="$TEMPLATE_DIR/.claude/agents/$agent.md"
  DEST="$PROJECT_PATH/.claude/agents/$agent.md"
  if [[ -f "$SRC" ]]; then
    if [[ ! -f "$DEST" ]]; then
      cp "$SRC" "$DEST"
      echo "   ✅ .claude/agents/$agent.md"
    else
      echo "   ⏭️  .claude/agents/$agent.md (already exists)"
    fi
  else
    echo "   ⚠️  Agent template not found: $agent.md"
  fi
done

# 4. Copy team config
echo ""
echo "📋 Copying team config..."
mkdir -p "$PROJECT_PATH/conductor"

TEAM_CONFIG_SRC="$TEMPLATE_DIR/team-configs/$TEAM_TYPE.md"
if [[ -f "$TEAM_CONFIG_SRC" ]]; then
  cp "$TEAM_CONFIG_SRC" "$PROJECT_PATH/conductor/team-config.md"
  echo "   ✅ conductor/team-config.md (from $TEAM_TYPE template)"
else
  echo "   ⚠️  No team config for type '$TEAM_TYPE'"
fi

echo ""
echo "✨ Done! Project initialized at: $PROJECT_PATH"
echo ""
echo "Next steps:"
echo "  1. Open $PROJECT_PATH in Claude Code"
echo "  2. Fill in CLAUDE.md with your actual project details"
echo "  3. Fill in conductor/product.md with product vision"
echo "  4. Fill in conductor/tech-stack.md with your decisions"
echo "  5. Run: /agent-team init \"Your first feature\""
