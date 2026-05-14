#!/usr/bin/env bash
# Checks whether the ehrQL development environment is ready in the current directory.
# Exits 0 and prints JSON status. Never exits non-zero — caller interprets status fields.

HAS_UV=false
HAS_PYPROJECT=false
HAS_EHRQL_DEP=false
HAS_EHRQL_CLI=false
HAS_ANALYSIS_DIR=false
HAS_DUMMY_TABLES=false

if command -v uv >/dev/null 2>&1 || [ -x "$HOME/.local/bin/uv" ]; then
    HAS_UV=true
fi

if [ -f "pyproject.toml" ]; then
    HAS_PYPROJECT=true
    if grep -q "opensafely-ehrql\|ehrql" pyproject.toml 2>/dev/null; then
        HAS_EHRQL_DEP=true
    fi
fi

if [ -x ".venv/bin/ehrql" ] || command -v ehrql >/dev/null 2>&1; then
    HAS_EHRQL_CLI=true
fi

if [ -d "analysis" ]; then
    HAS_ANALYSIS_DIR=true
fi

if [ -d "dummy-tables" ] && ls dummy-tables/*.csv >/dev/null 2>&1; then
    HAS_DUMMY_TABLES=true
fi

cat <<EOF
{
  "has_uv": $HAS_UV,
  "has_pyproject": $HAS_PYPROJECT,
  "has_ehrql_dep": $HAS_EHRQL_DEP,
  "has_ehrql_cli": $HAS_EHRQL_CLI,
  "has_analysis_dir": $HAS_ANALYSIS_DIR,
  "has_dummy_tables": $HAS_DUMMY_TABLES
}
EOF
