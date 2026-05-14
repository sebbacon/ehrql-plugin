#!/usr/bin/env bash
# Sets up the ehrQL Python environment in the current directory.
# Installs uv if missing, then syncs the project's Python dependencies.
set -euo pipefail

PLUGIN_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log() {
    printf '[ehrql-setup] %s\n' "$*"
}

ensure_uv() {
    if command -v uv >/dev/null 2>&1; then
        log "uv already installed ($(uv --version))"
        return
    fi
    if [ -x "$HOME/.local/bin/uv" ]; then
        export PATH="$HOME/.local/bin:$PATH"
        log "uv found at ~/.local/bin ($(uv --version))"
        return
    fi

    log "installing uv..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
    log "uv installed ($(uv --version))"
}

ensure_pyproject() {
    if [ -f "pyproject.toml" ]; then
        log "pyproject.toml found"
        return
    fi
    log "no pyproject.toml found — run scaffold-project.sh first to initialise the project"
    exit 1
}

main() {
    ensure_uv
    ensure_pyproject

    log "syncing Python environment (this may take a minute on first run)..."
    if [ -f "uv.lock" ]; then
        uv sync --frozen
    else
        uv sync
    fi

    log "verifying ehrql CLI..."
    if [ -x ".venv/bin/ehrql" ]; then
        .venv/bin/ehrql --version
    else
        uv run ehrql --version
    fi

    log "setup complete — run 'ehrql generate-dataset' or use .venv/bin/ehrql directly"
}

main "$@"
