#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../utils/bash/colors.bash"

local username="$1"
local password="$2"

if [[ -z "$username" || -z "$password" ]]; then
    print_error "Usage: bash create_hash_password.bash <username> <password>"
    return 1
fi

htpasswd -nb "$username" "$password" | sed -e 's/\\$/\\$\\$/g'

