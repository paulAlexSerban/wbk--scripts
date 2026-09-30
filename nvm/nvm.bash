#!/bin/bash
# Source from ~/.bashrc or ~/.zshrc. Do not execute.
# Auto-switches Node version when the current directory has a .nvmrc.

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

if [ -s "$NVM_DIR/nvm.sh" ]; then
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"
fi

# Bash completion only - noisy / broken under Zsh.
if [ -n "$BASH_VERSION" ] && [ -s "$NVM_DIR/bash_completion" ]; then
  # shellcheck disable=SC1091
  . "$NVM_DIR/bash_completion"
fi

use_nvmrc_if_present() {
  if [ ! -f .nvmrc ]; then
    return 0
  fi
  if ! command -v nvm >/dev/null 2>&1; then
    return 0
  fi
  nvm use >/dev/null 2>&1
}

if [ -n "$BASH_VERSION" ]; then
  if [[ ":${PROMPT_COMMAND}:" != *":use_nvmrc_if_present:"* ]]; then
    PROMPT_COMMAND="use_nvmrc_if_present${PROMPT_COMMAND:+; $PROMPT_COMMAND}"
  fi
elif [ -n "$ZSH_VERSION" ]; then
  if ! (( ${chpwd_functions[(Ie)use_nvmrc_if_present]} )); then
    chpwd_functions+=(use_nvmrc_if_present)
  fi
fi

use_nvmrc_if_present
