#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../utils/bash/colors.bash"

if ! command -v ssh >/dev/null 2>&1; then
    print_error "ssh not found"
    exit 1
fi

print_info "Path to the .pem file:"
read -r PEM_FILE
print_info "Username:"
read -r USERNAME
print_info "Host:"
read -r HOST

if [ -z "$PEM_FILE" ] || [ -z "$USERNAME" ] || [ -z "$HOST" ]; then
    print_error "pem file, username, and host are required"
    exit 1
fi

if [ ! -f "$PEM_FILE" ]; then
    print_error "PEM file not found: $PEM_FILE"
    exit 1
fi

chmod 400 "$PEM_FILE"
ssh -i "$PEM_FILE" "${USERNAME}@${HOST}"
