#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../utils/bash/colors.bash"

print_info "set git username: $(git config --global user.name ${GITHUB_USERNAME})${NC}"
print_info "set email: $(git config --global user.email ${GITHUB_EMAIL})${NC}"
