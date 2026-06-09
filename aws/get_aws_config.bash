#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../utils/bash/colors.bash"

print_info "current aws profile: $(aws configure get profile)"
print_info "current aws region: $(aws configure get region)"