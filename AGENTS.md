# Project Guidance

## Skill catalog metadata

Whenever a skill is updated, bump the catalog version in `VERSION`,
`.codex-plugin/plugin.json`, and `.claude-plugin/plugin.json`. Keep all three
versions identical, and run `bash tests/plugin-metadata.sh` to verify them.
