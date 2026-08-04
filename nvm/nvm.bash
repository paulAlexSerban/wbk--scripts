#!/bin/bash

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

function set_local_node_version() {
  local node_version
  node_version=$(cat .nvmrc)
  nvm install "$node_version"
  nvm use
}

if [ -f .nvmrc ] && [ -n "$BASH_VERSION" ]; then
  PROMPT_COMMAND="set_local_node_version; $PROMPT_COMMAND"
elif [ -f .nvmrc ] && [ -n "$ZSH_VERSION" ]; then
  chpwd_functions+=(nvm use)
  nvm use # Run on startup
else
  echo "no .nvmrc file found"
  echo "current node version: $(node -v)"
fi
