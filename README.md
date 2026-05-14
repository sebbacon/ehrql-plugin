# ehrql-plugin

A Claude Code / Codex plugin for authoring [ehrQL](https://docs.opensafely.org/ehrql/) dataset definitions in the [OpenSAFELY](https://www.opensafely.org/) ecosystem.

Provides:
- A skill that guides Claude through writing, testing, and iterating on ehrQL dataset definitions
- Automatic environment detection and setup (installs `uv` and `ehrql` if needed)
- Project scaffolding (starter `dataset_definition.py`, dummy tables, `pyproject.toml`)
- Bundled upstream ehrQL reference documentation

## Requirements

- macOS or Linux (the setup scripts use bash; Windows requires WSL — see below)
- `curl` (for installing `uv` if not already present)
- Internet access on first run (to download `uv` and `ehrql`)

Python 3.13+ is installed automatically by `uv` if needed.

### Windows

The shell scripts (`setup.sh`, `scaffold-project.sh`, etc.) do not run natively on Windows. Options:

- **WSL (recommended)**: Run Claude Code or Codex inside a WSL2 terminal — everything works as on Linux.
- **Git Bash**: May work for basic script execution but is not tested.
- **Skill only**: The skill guidance and templates work on any OS. Install `uv` and `ehrql` manually (`winget install astral-sh.uv`, then `uv sync`), then use the plugin for skill guidance only.

## Installation

### Claude Code

```bash
# Add as a marketplace, then install
claude plugins marketplace add https://github.com/opensafely-core/ehrql-plugin.git
claude plugins install ehrql-authoring
```

Or load for a single session without installing:
```bash
claude --plugin-url https://github.com/opensafely-core/ehrql-plugin/archive/refs/heads/main.zip
```
```

### Codex

Codex installs plugins through its built-in plugin browser — run `/plugins` in the CLI or open the Plugins section in the Codex app. There is no CLI install command equivalent to `claude plugins install`.

**For skill-only use** (no plugin browser needed), clone the repo and symlink the skill into Codex's discovery path:

```bash
git clone https://github.com/opensafely-core/ehrql-plugin ~/ehrql-plugin

# User-wide (available in all projects)
mkdir -p ~/.agents/skills
ln -s ~/ehrql-plugin/skills/ehrql-dataset-authoring ~/.agents/skills/ehrql-dataset-authoring

# Or repo-local (available in one project only)
mkdir -p .agents/skills
ln -s ~/ehrql-plugin/skills/ehrql-dataset-authoring .agents/skills/ehrql-dataset-authoring
```

Invoke with `$ehrql-dataset-authoring` or let Codex select it implicitly.

> **Note:** The SessionStart environment check hook works automatically in Claude Code. In Codex, run `bash ~/ehrql-plugin/scripts/check-env.sh` manually to see what's missing, or just ask Codex to set up the project and it will use the skill instructions to guide you.

## Usage

### Starting a new ehrQL project

Open Claude Code (or Codex) in an empty directory and say:

> "Set up a new ehrQL project here"

Claude will scaffold the project structure and install dependencies automatically.

### Working on an existing project

Open Claude Code in a directory that contains `analysis/dataset_definition.py` and say:

> "Update the dataset definition to include patients with a diagnosis of hypertension in the last 5 years"

The skill activates automatically when editing `analysis/dataset_definition.py` or asking about ehrQL.

### Slash command

You can also invoke the skill explicitly:

```
/ehrql-dataset-authoring
```

## What the SessionStart hook does

When you open a session, the plugin checks:

1. Is `uv` installed?
2. Is there a `pyproject.toml` with an ehrql dependency?
3. Is the ehrql CLI available in `.venv/`?
4. Do `analysis/` and `dummy-tables/` directories exist?

Claude uses this information to proactively offer setup or scaffolding help without you having to ask.

## Scripts

| Script | Purpose |
|--------|---------|
| `scripts/setup.sh` | Install `uv` + sync Python environment |
| `scripts/scaffold-project.sh` | Copy starter files into current directory + run setup |
| `scripts/check-env.sh` | Print JSON status of the current environment |

## Updating ehrql version

Edit `templates/pyproject.toml` and change the `@v1.51.9` tag to the desired version. Run `scripts/setup.sh` in any project to update.

## License

MIT
