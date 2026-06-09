#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../utils/bash/colors.bash"

IP=$(ifconfig en0 | awk '$1 == "inet" {print $2}')
print_info "your ip is: $IP"