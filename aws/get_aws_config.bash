#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../utils/bash/colors.bash"

if ! command -v aws >/dev/null 2>&1; then
    print_error "aws CLI not found"
    exit 1
fi

print_info "AWS_PROFILE: ${AWS_PROFILE:-default}"
print_info "region: $(aws configure get region 2>/dev/null || echo "(unset)")"
aws configure list
