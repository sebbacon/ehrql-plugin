#!/usr/bin/env bash
# Publishes the current committed project to a new template-backed GitHub repo.
set -euo pipefail

RESEARCH_TEMPLATE="opensafely/research-template"
PUBLISH_DIR=""

cleanup() {
    if [ -n "$PUBLISH_DIR" ] && [ -d "$PUBLISH_DIR" ]; then
        rm -rf "$PUBLISH_DIR"
    fi
}
trap cleanup EXIT

usage() {
    printf 'usage: %s OWNER/REPOSITORY (--private|--public|--internal)\n' "$0" >&2
}

main() {
    if [ "$#" -ne 2 ]; then
        usage
        exit 2
    fi

    local repository="$1"
    local visibility_flag="$2"
    if [[ ! "$repository" =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]]; then
        printf 'repository must have the form OWNER/REPOSITORY\n' >&2
        exit 2
    fi
    case "$visibility_flag" in
        --private|--public|--internal) ;;
        *) usage; exit 2 ;;
    esac

    command -v gh >/dev/null 2>&1 || {
        printf 'gh is required; install and authenticate GitHub CLI first\n' >&2
        exit 1
    }
    gh auth status >/dev/null

    local project_root
    project_root="$(git rev-parse --show-toplevel 2>/dev/null)" || {
        printf 'the project must be a Git repository\n' >&2
        exit 1
    }
    if [ "$project_root" != "$(pwd -P)" ]; then
        printf 'run this script from the project Git root: %s\n' "$project_root" >&2
        exit 1
    fi
    if [ -n "$(git status --porcelain)" ]; then
        printf 'commit or discard all project changes before publishing\n' >&2
        exit 1
    fi
    git cat-file -e HEAD:.devcontainer/devcontainer.json 2>/dev/null || {
        printf 'the committed project has no .devcontainer/devcontainer.json\n' >&2
        exit 1
    }
    git cat-file -e HEAD:project.yaml 2>/dev/null || {
        printf 'the committed project has no project.yaml\n' >&2
        exit 1
    }

    printf '[ehrql-codespace] creating %s from %s\n' "$repository" "$RESEARCH_TEMPLATE"
    gh repo create "$repository" "$visibility_flag" --template "$RESEARCH_TEMPLATE"

    PUBLISH_DIR="$(mktemp -d)"
    local checkout="$PUBLISH_DIR/repository"
    local snapshot="$PUBLISH_DIR/project.tar"
    gh repo clone "$repository" "$checkout"

    git archive --format=tar --output="$snapshot" HEAD
    git -C "$checkout" rm -qr .
    tar -xf "$snapshot" -C "$checkout"
    git -C "$checkout" add -A
    if ! git -C "$checkout" diff --cached --quiet; then
        git -C "$checkout" commit -m "Add scaffolded ehrQL study"
        git -C "$checkout" push origin HEAD
    fi

    printf '[ehrql-codespace] ready: https://codespaces.new/%s\n' "$repository"
}

main "$@"
