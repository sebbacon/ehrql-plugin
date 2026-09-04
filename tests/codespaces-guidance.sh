#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXPECTED_COMMAND="opensafely exec ehrql:v1 generate-dataset analysis/dataset_definition.py --dummy-tables dummy-tables"

grep -Fq "$EXPECTED_COMMAND" "$ROOT/skills/ehrql-dataset-authoring/SKILL.md"
grep -Fq "$EXPECTED_COMMAND" "$ROOT/skills/ehrql-dataset-authoring/references/codespaces.md"

printf 'codespaces-guidance test passed\n'
