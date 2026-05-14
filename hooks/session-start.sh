#!/usr/bin/env bash
# SessionStart hook: checks the ehrQL environment and emits a status message
# to Claude's context so it can proactively offer help.
set -uo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STATUS=$("$PLUGIN_ROOT/scripts/check-env.sh" 2>/dev/null)

has_uv=$(echo "$STATUS" | grep '"has_uv"' | grep -c 'true' || true)
has_pyproject=$(echo "$STATUS" | grep '"has_pyproject"' | grep -c 'true' || true)
has_ehrql_cli=$(echo "$STATUS" | grep '"has_ehrql_cli"' | grep -c 'true' || true)
has_analysis=$(echo "$STATUS" | grep '"has_analysis_dir"' | grep -c 'true' || true)
has_dummy=$(echo "$STATUS" | grep '"has_dummy_tables"' | grep -c 'true' || true)

# Emit plain-text status to Claude's context
echo "[ehrql-plugin]"

if [ "$has_uv" -eq 0 ]; then
    echo "uv is not installed. Offer to install it by running: bash $PLUGIN_ROOT/scripts/setup.sh"
fi

if [ "$has_pyproject" -eq 0 ]; then
    echo "No pyproject.toml found in the current directory. This does not appear to be an ehrQL project."
    echo "Offer to scaffold a new project by running: bash $PLUGIN_ROOT/scripts/scaffold-project.sh"
elif [ "$has_ehrql_cli" -eq 0 ]; then
    echo "pyproject.toml found but ehrql CLI is not installed. Offer to run setup: bash $PLUGIN_ROOT/scripts/setup.sh"
fi

if [ "$has_analysis" -eq 0 ]; then
    echo "No analysis/ directory found. Offer to scaffold one: bash $PLUGIN_ROOT/scripts/scaffold-project.sh"
fi

if [ "$has_dummy" -eq 0 ]; then
    echo "No dummy-tables/ CSVs found. Without these, dummy-data generation will use auto-generated data."
fi

if [ "$has_uv" -eq 1 ] && [ "$has_pyproject" -eq 1 ] && [ "$has_ehrql_cli" -eq 1 ] && [ "$has_analysis" -eq 1 ]; then
    echo "ehrQL environment ready."
fi
