# Git profile switcher

Automates switching between GitHub identities: **SSH keys**, **Git name/email**, and optional **GPG signing keys** — by folder path or via `gprofile`.

## Requirements

- `jq` — macOS: `brew install jq` · Ubuntu/Debian: `sudo apt install jq`
- Separate SSH keys per profile (see [ssh_and_gpg_keys.md](ssh_and_gpg_keys.md))

## Config

Create `$HOME/.git_profiles.json` (override path with `GIT_CONFIG_JSON`):

```json
{
  "personal": {
    "name": "Your Name",
    "email": "personal@email.com",
    "ssh_key": "~/.ssh/id_ed25519_personal",
    "path": "projects/personal",
    "gpg_key": ""
  },
  "work": {
    "name": "Work Name",
    "email": "work@company.com",
    "ssh_key": "~/.ssh/id_ed25519_work",
    "path": "projects/work",
    "gpg_key": "ABC12345"
  }
}
```

`path` is matched as a **path segment** inside `$PWD` (so `personal` will not match `personal-projects`).

## Install

Source the script from your shell rc (do **not** paste the script body into it):

```bash
# ~/.bashrc or ~/.zshrc
source /path/to/wbk--scripts/git/set_git_profile/set_git_profile.bash
```

Reload:

```bash
source ~/.bashrc   # or ~/.zshrc
```

## Usage

**Automatic:** `cd` into a directory whose path contains a profile’s `path` segment. The hook switches only when the global `user.email` differs (quiet otherwise).

**Manual:**

```bash
gprofile work
gprofile personal
```

## SSH config tip

If multiple GitHub accounts share `github.com`, prefer:

```text
Host github.com
  IdentitiesOnly yes
```

so SSH uses the key loaded into the agent by this script.
