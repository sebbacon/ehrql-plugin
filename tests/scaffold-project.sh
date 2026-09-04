#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

git init -q "$TEST_ROOT/template"
mkdir -p "$TEST_ROOT/template/.devcontainer" "$TEST_ROOT/template/analysis"
printf '{"name":"OpenSAFELY"}\n' > "$TEST_ROOT/template/.devcontainer/devcontainer.json"
printf 'template dataset\n' > "$TEST_ROOT/template/analysis/dataset_definition.py"
printf 'version: 4.0\n' > "$TEST_ROOT/template/project.yaml"
git -C "$TEST_ROOT/template" add .
git -C "$TEST_ROOT/template" -c user.name=Test -c user.email=test@example.com commit -qm 'Create template'

mkdir "$TEST_ROOT/project"
(
    cd "$TEST_ROOT/project"
    RESEARCH_TEMPLATE_URL="$TEST_ROOT/template" \
        bash "$ROOT/scripts/scaffold-project.sh" --skip-setup
)

test -f "$TEST_ROOT/project/.devcontainer/devcontainer.json"
test -f "$TEST_ROOT/project/project.yaml"
grep -q 'from ehrql import create_dataset' "$TEST_ROOT/project/analysis/dataset_definition.py"
test -f "$TEST_ROOT/project/dummy-tables/patients.csv"
test ! -d "$TEST_ROOT/project/.git"

printf 'scaffold-project test passed\n'
