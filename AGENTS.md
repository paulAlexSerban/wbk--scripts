# AGENTS.md

Guidance for AI agents working in this repository.

## What this repo is

Personal collection of **development automation scripts** (mostly Bash, some Python). Scripts are organized by domain and meant to be run directly or sourced into a shell profile.

There is no app framework, test suite, or build pipeline. Prefer small, self-contained scripts over shared libraries beyond what already exists in `utils/`.

## Layout

```
aws/          AWS helpers (config, EC2 SSH)
docker/       Docker prune / cleanup
files/        File utilities (Python)
git/          Git identity / profile switching
iterm/        iTerm helpers (macOS, sourced)
k8s/          EKS kubeconfig + current context
networking/   IP helpers
nvm/          NVM + .nvmrc auto-use hooks
ssh/          Interactive SSH with PEM
utils/bash/   Shared Bash helpers (colors, OS checks)
archive/      Frozen leftovers — do not use for new work
```

Put new scripts in the matching domain folder. Create a new top-level folder only when the domain does not fit an existing one.

Do **not** revive or extend scripts under `archive/` — fix/port into an active domain folder instead if something becomes useful again.

## Languages & tooling

| Kind | Notes |
|------|--------|
| Bash | Primary language. Shebang `#!/bin/bash`. Extension `.bash`. |
| Python | `#!/usr/bin/env python3`. Prefer stdlib + `argparse`. |
| Secrets | Copy `.env.example` → `.env` (gitignored). Never commit `.env` or real keys. |
| Node | Not used by active scripts. Archived one-off lived under `archive/files/`. |

## Bash conventions

Most runnable Bash scripts follow this pattern:

```bash
#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../utils/bash/colors.bash"
```

Rules:

- Prefer relative `source` paths from the script’s own directory after the `cd "$(dirname "$0")"` guard.
- Use `print_info` / `print_success` / `print_warning` / `print_error` from `utils/bash/colors.bash` for user-facing messages.
- Reuse `utils/bash/is_linux.bash` and `utils/bash/is_macos.bash` for OS checks instead of re-implementing `uname` logic.
- Scripts that need credentials should `source` the repo-root `.env` (see `aws/ssh_to_ec2.bash`), not hardcode values.
- Validate required args / env vars early and `exit 1` (or `return` if meant to be sourced) with a clear usage message.
- Prefer `command -v` checks for optional dependencies (`jq`, `docker`, `aws`, `kubectl`, etc.).
- Quote variable expansions. Use `snake_case` filenames with a clear verb/noun (`check_*`, `get_*`, `set_*`, `find_*`, `prune_*`, `update_*`).

### Shell-hook scripts

Some scripts are designed to be **sourced** into `.bashrc` / `.zshrc` and attach directory-change hooks (e.g. `nvm/nvm.bash`, `git/set_git_profile/set_git_profile.bash`):

- Bash: prepend to `PROMPT_COMMAND`
- Zsh: append to `chpwd_functions`

Do not `cd "$(dirname "$0")"` in hook scripts that must preserve the user’s working directory. Keep hook side effects quiet when nothing changed.

## Python conventions

- Keep scripts CLI-first with `argparse`.
- Guard entry with `if __name__ == "__main__":`.
- Handle `PermissionError` / missing paths gracefully when walking filesystems.
- Put short usage examples in a module docstring or trailing comments (see `files/find_large_files.py`, `files/bundle_file_contents.py`).
- Avoid new third-party Python deps unless clearly justified; stdlib is preferred.

## Adding a new script

1. Choose the domain folder (or add a new top-level domain).
2. Name files with `snake_case` and a clear verb/noun.
3. Match the existing language style in that folder.
4. For Bash: start from the `cd` + `colors.bash` template above.
5. Document non-obvious setup in a nearby `readme.md` only when the script needs external config (example: `git/set_git_profile/`).
6. Update `.env.example` if new secrets/config keys are required — never put real values there.
7. Update the inventory table in `README.md`.

## Safety & scope

- Do not commit secrets, PEM keys, SSH private keys, or filled `.env` files.
- Do not force-push, rewrite history, or change git config unless the user explicitly asks.
- Scripts that mutate global Git / SSH agent state (`git/set_git_profile/`) are intentional; change them carefully and preserve both Bash and Zsh hook paths.
- Keep changes focused: one script or one related fix per change set unless the user asks for a broader cleanup.
- There are no automated tests; manually sanity-check scripts after edits (run with `--help` / dry paths, or source hooks in a throwaway shell).

## Commit style

Recent history prefers short conventional prefixes:

- `feat: …` — new script or capability
- `fix: …` — bug fix
- `updates` / brief imperative messages also appear; prefer `feat` / `fix` when committing

Only commit when the user asks.
