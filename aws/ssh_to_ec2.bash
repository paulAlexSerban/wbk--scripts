#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../utils/bash/colors.bash"

ENV_FILE="../.env"
if [ ! -f "$ENV_FILE" ]; then
    print_error "missing $ENV_FILE - copy .env.example to .env and set PEM_KEY_FILE / EC2_INSTANCE_IP"
    exit 1
fi

# shellcheck disable=SC1091
source "$ENV_FILE"

if ! command -v ssh >/dev/null 2>&1; then
    print_error "ssh not found"
    exit 1
fi

if [ -z "$PEM_KEY_FILE" ] || [ -z "$EC2_INSTANCE_IP" ]; then
    print_error "pem file or ec2 ip not configured"
    exit 1
fi

if [ ! -f "$PEM_KEY_FILE" ]; then
    print_error "PEM file not found: $PEM_KEY_FILE"
    exit 1
fi

print_info "ssh to ec2 ($EC2_INSTANCE_IP)"
chmod 0400 "$PEM_KEY_FILE"
ssh -i "$PEM_KEY_FILE" "ec2-user@$EC2_INSTANCE_IP"
