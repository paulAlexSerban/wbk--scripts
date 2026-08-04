# Archive

Frozen leftovers from earlier iterations of this repo. Scripts here are **superseded, broken, or one-offs** — not for daily use.

| Path | Why archived |
|------|----------------|
| `git/set_git_local_config_profile.bash` | Broken; superseded by `git/set_git_profile/` |
| `security/create-hash-password.bash` | Illegal `local`/`return` when executed; password on argv |
| `yarn/yarn_cache_clean.bash` | Unguarded `rm -rf node_modules` |
| `monitoring/sysinfo.bash` | Dumps full `printenv` (secret leak risk) |
| `networking/check_connection_speed.bash` | Broken dependency check |
| `networking/check_internet_connection.bash` | Thin ping wrapper; always exits 0 |
| `docker/check_docker_container.bash` | NRPE-style monitor; replaced by `docker/prune_docker.bash` |
| `files/pdf_multipler.js` | Hardcoded one-off PDF chore (`pdf-lib`) |

Prefer the active scripts under the domain folders at the repo root.