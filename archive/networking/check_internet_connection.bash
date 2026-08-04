#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../utils/bash/colors.bash"

ping -c 1 google.com &>/dev/null
if [ $? -eq 0 ]; then
    print_info "you are connected to the internet."
else
    print_error "you are not connected to the internet."
fi