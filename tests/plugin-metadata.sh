#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
version_file="$repo_root/VERSION"

if [[ ! -f "$version_file" ]]; then
  echo "missing release version file: $version_file" >&2
  exit 1
fi

release_version="$(<"$version_file")"
if [[ ! "$release_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "VERSION must contain a strict semantic version" >&2
  exit 1
fi

python3 - "$repo_root" "$release_version" <<'PY'
import json
import pathlib
import sys

repo_root = pathlib.Path(sys.argv[1])
release_version = sys.argv[2]

for relative_path in (
    ".claude-plugin/plugin.json",
    ".codex-plugin/plugin.json",
):
    manifest_path = repo_root / relative_path
    manifest = json.loads(manifest_path.read_text())
    actual_version = manifest["version"]
    if actual_version != release_version:
        raise SystemExit(
            f"{relative_path} version {actual_version!r} does not match "
            f"VERSION {release_version!r}"
        )
PY
