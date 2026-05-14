#!/usr/bin/env bash
# Scaffolds a new ehrQL project in the current directory from bundled templates.
# Safe to run in an existing directory — skips files that already exist.
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES="$PLUGIN_ROOT/templates"

log() {
    printf '[ehrql-scaffold] %s\n' "$*"
}

copy_if_missing() {
    local src="$1"
    local dst="$2"
    if [ -e "$dst" ]; then
        log "skipping $dst (already exists)"
    else
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        log "created $dst"
    fi
}

main() {
    log "scaffolding ehrQL project in $(pwd)..."

    copy_if_missing "$TEMPLATES/pyproject.toml" "pyproject.toml"
    copy_if_missing "$TEMPLATES/analysis/dataset_definition.py" "analysis/dataset_definition.py"

    for csv in "$TEMPLATES/dummy-tables/"*.csv; do
        filename="$(basename "$csv")"
        copy_if_missing "$csv" "dummy-tables/$filename"
    done

    log ""
    log "scaffold complete. Next steps:"
    log "  1. Run: bash $PLUGIN_ROOT/scripts/setup.sh"
    log "  2. Edit analysis/dataset_definition.py to match your study spec"
    log "  3. Generate dummy output: .venv/bin/ehrql generate-dataset analysis/dataset_definition.py --output dataset.csv"
    log ""
    log "Running setup now..."
    bash "$PLUGIN_ROOT/scripts/setup.sh"
}

main "$@"
