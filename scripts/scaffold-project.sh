#!/usr/bin/env bash
# Scaffolds a new ehrQL project from the OpenSAFELY research template, then adds
# the plugin's ehrQL starter files. Existing files are never overwritten.
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATES="$PLUGIN_ROOT/templates"
RESEARCH_TEMPLATE_URL="${RESEARCH_TEMPLATE_URL:-https://github.com/opensafely/research-template.git}"
RUN_SETUP=true
STAGING_DIR=""

cleanup() {
    if [ -n "$STAGING_DIR" ] && [ -d "$STAGING_DIR" ]; then
        rm -rf "$STAGING_DIR"
    fi
}
trap cleanup EXIT

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

copy_research_template() {
    STAGING_DIR="$(mktemp -d)"
    local checkout="$STAGING_DIR/research-template"

    log "fetching base template from $RESEARCH_TEMPLATE_URL"
    git clone --depth 1 "$RESEARCH_TEMPLATE_URL" "$checkout"
    while IFS= read -r -d '' source; do
        local relative="${source#"$checkout/"}"
        if [ -d "$source" ]; then
            mkdir -p "$relative"
        elif [ ! -e "$relative" ]; then
            mkdir -p "$(dirname "$relative")"
            cp -P "$source" "$relative"
        fi
    done < <(find "$checkout" -mindepth 1 -path "$checkout/.git" -prune -o -print0)
    log "copied OpenSAFELY research template"
}

main() {
    if [ "${1:-}" = "--skip-setup" ]; then
        RUN_SETUP=false
        shift
    fi
    if [ "$#" -ne 0 ]; then
        printf 'usage: %s [--skip-setup]\n' "$0" >&2
        exit 2
    fi

    log "scaffolding ehrQL project in $(pwd)..."

    copy_if_missing "$TEMPLATES/pyproject.toml" "pyproject.toml"
    copy_if_missing "$TEMPLATES/analysis/dataset_definition.py" "analysis/dataset_definition.py"

    for csv in "$TEMPLATES/dummy-tables/"*.csv; do
        filename="$(basename "$csv")"
        copy_if_missing "$csv" "dummy-tables/$filename"
    done
    copy_research_template

    log ""
    log "scaffold complete. Next steps:"
    log "  1. Run: bash $PLUGIN_ROOT/scripts/setup.sh"
    log "  2. Edit analysis/dataset_definition.py to match your study spec"
    log "  3. Add assurance scenarios: analysis/test_dataset_definition.py"
    log "  4. Run assurance tests: .venv/bin/ehrql assure analysis/test_dataset_definition.py"
    log "  5. Generate dummy output: .venv/bin/ehrql generate-dataset analysis/dataset_definition.py --output dataset.csv"
    log ""
    if [ "$RUN_SETUP" = true ]; then
        log "Running setup now..."
        bash "$PLUGIN_ROOT/scripts/setup.sh"
    else
        log "Skipping setup as requested."
    fi
}

main "$@"
