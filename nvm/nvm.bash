#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../utils/bash/colors.bash"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

function set_local_node_version() {
  local node_version
  node_version=$(cat .nvmrc)
  nvm install "$node_version"
  nvm use
}

if [ -f .nvmrc ]; then
  set_local_node_version
else
  print_error "no .nvmrc file found"
  print_info "current node version: ${BLUE}$(node -v)${NC}"
fi
