# Figma Workspace

This workspace contains a refresh script for vendoring the Figma Codex plugin
from the OpenAI plugins repository.

## Refreshing

Run:

```bash
./scripts/refresh-figma-plugin.sh
```

The script deletes and recreates these generated paths:

- `figma-codex-plugin/`
- `.agents/skills/`
- `.codex/config.toml`

It sparse-clones `plugins/figma` from `https://github.com/openai/plugins.git`,
copies the plugin source into `figma-codex-plugin/`, copies the plugin skills
into `.agents/skills/`, and writes the Figma MCP config for Codex.

Generated plugin files are intentionally ignored by git. The repository source
of truth is this README plus `scripts/refresh-figma-plugin.sh`.
