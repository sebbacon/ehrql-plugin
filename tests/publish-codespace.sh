#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEST_ROOT="$(mktemp -d)"
trap 'rm -rf "$TEST_ROOT"' EXIT

mkdir -p "$TEST_ROOT/bin" "$TEST_ROOT/template/.devcontainer" "$TEST_ROOT/project/analysis"
printf '{}\n' > "$TEST_ROOT/template/.devcontainer/devcontainer.json"
printf 'template\n' > "$TEST_ROOT/template/project.yaml"
git init -q "$TEST_ROOT/template"
git -C "$TEST_ROOT/template" add .
git -C "$TEST_ROOT/template" -c user.name=Test -c user.email=test@example.com commit -qm 'Create template'

mkdir -p "$TEST_ROOT/project/.devcontainer"
printf '{}\n' > "$TEST_ROOT/project/.devcontainer/devcontainer.json"
printf 'version: 4.0\n' > "$TEST_ROOT/project/project.yaml"
printf 'edited dataset\n' > "$TEST_ROOT/project/analysis/dataset_definition.py"
git init -q "$TEST_ROOT/project"
git -C "$TEST_ROOT/project" config user.name Test
git -C "$TEST_ROOT/project" config user.email test@example.com
git -C "$TEST_ROOT/project" add .
git -C "$TEST_ROOT/project" commit -qm 'Author study'

cp "$ROOT/tests/fixtures/gh" "$TEST_ROOT/bin/gh"
chmod +x "$TEST_ROOT/bin/gh"

output=$(
    cd "$TEST_ROOT/project"
    PATH="$TEST_ROOT/bin:$PATH" \
        FAKE_TEMPLATE="$TEST_ROOT/template" \
        FAKE_SEED="$TEST_ROOT/seed" \
        FAKE_REMOTE="$TEST_ROOT/remote.git" \
        GIT_AUTHOR_NAME=Test GIT_AUTHOR_EMAIL=test@example.com \
        GIT_COMMITTER_NAME=Test GIT_COMMITTER_EMAIL=test@example.com \
        bash "$ROOT/scripts/publish-codespace.sh" test-owner/test-study --private
)

git clone -q "$TEST_ROOT/remote.git" "$TEST_ROOT/result"
grep -q 'edited dataset' "$TEST_ROOT/result/analysis/dataset_definition.py"
grep -q 'https://codespaces.new/test-owner/test-study' <<< "$output"

printf 'publish-codespace test passed\n'
