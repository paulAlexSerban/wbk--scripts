#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../utils/bash/colors.bash"

if ! command -v git >/dev/null 2>&1; then
    print_error "git not found"
    exit 1
fi

print_info "git username: $(git config user.name 2>/dev/null || echo "(unset)")"
print_info "git email: $(git config user.email 2>/dev/null || echo "(unset)")"
