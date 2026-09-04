# Providing a preloaded GitHub Codespace

Use this workflow only when the user asks to receive or share the finished work
as a GitHub Codespace. The Codespace must start from a committed, validated
project based on `opensafely/research-template`.

## Prepare the snapshot

1. Complete the dataset definition, assurance tests, dummy-data generation, and
   README update required by the main workflow.
2. Verify that the README tells Codespace users to run the scaffolded definition
   with its supplied dummy tables:
   ```sh
   opensafely exec ehrql:v1 generate-dataset analysis/dataset_definition.py --dummy-tables dummy-tables
   ```
3. Ensure the project is a Git repository. Review `git status`, the staged diff,
   and ignored files for secrets or patient data before committing the intended
   project files.
4. Commit the complete project snapshot. The publication script refuses a dirty
   worktree and publishes only files in `HEAD`; ignored and uncommitted files are
   not uploaded.

## Confirm the GitHub mutation

When offering to publish the project, ask the user for a repository name and
privacy setting. Alternatively, make the offer concrete by suggesting an
`OWNER/REPOSITORY` and one of private, public, or internal. A suggestion is not
authorization to create the repository.

Determine the destination `OWNER/REPOSITORY` and whether it should be private,
public, or internal. Do not infer visibility. Check `gh auth status`, and confirm
that the authenticated account can create a repository for the chosen owner.

Immediately before publication, tell the user that the next command will create
a GitHub repository from `opensafely/research-template` and push the committed
study files. Obtain explicit confirmation unless their latest instruction already
unambiguously authorizes that exact repository, owner, and visibility.

## Publish and hand off

From the project root, run:

```bash
bash "$PLUGIN_ROOT/scripts/publish-codespace.sh" OWNER/REPOSITORY --private
```

Use `--public` or `--internal` only when that is the confirmed visibility. The
script creates the repository from the OpenSAFELY template, clones it into a
temporary directory, applies the committed project snapshot, commits the result,
pushes it, and prints:

```text
https://codespaces.new/OWNER/REPOSITORY
```

Return that URL to the user. Do not run `gh codespace create` unless they
separately ask you to create the billable Codespace itself.

If publication fails after repository creation, report the repository URL and
the exact failing step. Do not delete or recreate the repository without fresh
authorization.
