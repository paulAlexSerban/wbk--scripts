#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../.env"
source "../utils/bash/colors.bash"

print_info "ssh to ec2"
if [ -z "$PEM_KEY_FILE" ] || [ -z "$EC2_INSTANCE_IP" ]; then
    print_error "pem file or ec2 ip not configured$"
    return
fi
chmod 0400 $PEM_KEY_FILE
ssh -i $PEM_KEY_FILE ec2-user@$EC2_INSTANCE_IP