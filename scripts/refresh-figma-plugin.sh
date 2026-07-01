#!/usr/bin/env bash
set -euo pipefail

REPO_URL="${FIGMA_PLUGIN_REPO_URL:-https://github.com/openai/plugins.git}"
REF="${FIGMA_PLUGIN_REF:-main}"
SOURCE_PATH="${FIGMA_PLUGIN_SOURCE_PATH:-plugins/figma}"

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLUGIN_DIR="$ROOT_DIR/figma-codex-plugin"
AGENT_SKILLS_DIR="$ROOT_DIR/.agents/skills"
CODEX_DIR="$ROOT_DIR/.codex"

TMP_ROOT="${TMPDIR:-/tmp}"
TMP_DIR="$(mktemp -d "$TMP_ROOT/figma-plugin-refresh.XXXXXX")"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "Cloning $REPO_URL#$REF:$SOURCE_PATH"
git clone --depth 1 --filter=blob:none --sparse --branch "$REF" "$REPO_URL" "$TMP_DIR"
git -C "$TMP_DIR" sparse-checkout set "$SOURCE_PATH"

SOURCE_DIR="$TMP_DIR/$SOURCE_PATH"
if [[ ! -d "$SOURCE_DIR" ]]; then
  echo "Expected source directory not found: $SOURCE_PATH" >&2
  exit 1
fi

echo "Refreshing figma-codex-plugin"
rm -rf "$PLUGIN_DIR"
cp -R "$SOURCE_DIR" "$PLUGIN_DIR"

if [[ ! -d "$PLUGIN_DIR/skills" ]]; then
  echo "Expected cloned plugin to contain a skills directory" >&2
  exit 1
fi

echo "Refreshing .agents/skills"
rm -rf "$AGENT_SKILLS_DIR"
mkdir -p "$AGENT_SKILLS_DIR"
cp -R "$PLUGIN_DIR/skills/." "$AGENT_SKILLS_DIR/"

if [[ -f "$PLUGIN_DIR/LICENSE.txt" ]]; then
  cp "$PLUGIN_DIR/LICENSE.txt" "$AGENT_SKILLS_DIR/FIGMA_LICENSE.txt"
fi

echo "Refreshing .codex/config.toml"
mkdir -p "$CODEX_DIR"
cat > "$CODEX_DIR/config.toml" <<'TOML'
[mcp_servers.figma]
url = "https://mcp.figma.com/mcp"
oauth_resource = "https://mcp.figma.com/mcp"
TOML

echo "Done."
