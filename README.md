# Scripts

Personal collection of development automation scripts (mostly Bash, some Python).

## Setup

```bash
# EC2 SSH credentials
cp .env.example .env   # then edit PEM_KEY_FILE / EC2_INSTANCE_IP

# Optional shell hooks (source from ~/.bashrc or ~/.zshrc)
source /path/to/wbk--scripts/nvm/nvm.bash
source /path/to/wbk--scripts/git/set_git_profile/set_git_profile.bash
```

Git profiles: see [git/set_git_profile/readme.md](git/set_git_profile/readme.md).

## Active scripts

| Domain                 | Script                                          | Purpose                                        |
| ---------------------- | ----------------------------------------------- | ---------------------------------------------- |
| `aws/`                 | `get_aws_config.bash`                           | Show AWS profile / region / `configure list`   |
| `aws/`                 | `ssh_to_ec2.bash`                               | SSH to EC2 using `.env` PEM + IP               |
| `docker/`              | `prune_docker.bash`                             | Confirm + run `docker system prune`            |
| `files/`               | `bundle_file_contents.py`                       | Bundle matching sources into one Markdown file |
| `files/`               | `find_large_files.py`                           | List files above a size threshold              |
| `files/`               | `find_duplicate_file_names.py`                  | Duplicate **basenames** (not content)          |
| `files/`               | `find_duplicate_files.py`                       | Duplicate files by content hash                |
| `git/`                 | `get_git_local_config.bash`                     | Print current Git user.name / user.email       |
| `git/set_git_profile/` | `set_git_profile.bash`                          | Auto/manual GitHub identity switch (hook)      |
| `iterm/`               | `tab.bash`                                      | Open macOS Terminal/iTerm tabs (sourced)       |
| `k8s/`                 | `update_eks_kubeconfig.bash`                    | Update kubeconfig for all EKS clusters         |
| `k8s/`                 | `get_k8s_context.bash`                          | Show current kubectl context / namespace       |
| `networking/`          | `get_ip.bash`                                   | Local + public IP (Linux/macOS)                |
| `nvm/`                 | `nvm.bash`                                      | NVM load + `.nvmrc` auto-use (hook)            |
| `ssh/`                 | `ssh_with_pem.bash`                             | Interactive SSH with a PEM key                 |
| `utils/bash/`          | `colors.bash`, `is_linux.bash`, `is_macos.bash` | Shared helpers                                 |

## Archive

Weak or superseded scripts live under [`archive/`](archive/) — see that folder’s README. Not for daily use.

## Agent notes

Conventions for AI agents: [AGENTS.md](AGENTS.md).
