#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../utils/bash/colors.bash"

if [ -x "$(command -v speedtest --version)" ]; then
    print_info "checking connection speed..."
    speedtest
    print_info "connection speed check complete."
else
    print_error "speedtest is not installed."
    print_info "go to https://www.speedtest.net/apps/cli"
fi