#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../utils/bash/colors.bash"
print_info "Path to the .pem file:"
read PEM_FILE
print_info "Username:"
read USERNAME
print_info "Host:"
read HOST
chmod 400 ${PEM_FILE}
ssh -i ${PEM_FILE} ${USERNAME}@${HOST}