#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../utils/bash/colors.bash"
source "../utils/bash/is_linux.bash"
source "../utils/bash/is_macos.bash"

get_local_ip() {
    if is_macos; then
        ifconfig en0 2>/dev/null | awk '$1 == "inet" {print $2; exit}'
        return
    fi

    if ! is_linux; then
        return
    fi

    if command -v ip >/dev/null 2>&1; then
        local global_ip
        global_ip=$(ip -4 -o addr show scope global 2>/dev/null | awk '{print $4}' | cut -d/ -f1 | head -n 1)
        if [ -n "$global_ip" ]; then
            echo "$global_ip"
            return
        fi
    fi

    hostname -I 2>/dev/null | awk '{print $1}'
}

get_public_ip() {
    if command -v curl >/dev/null 2>&1; then
        curl -4 -fsS --max-time 5 https://ifconfig.me/ip 2>/dev/null \
            || curl -4 -fsS --max-time 5 https://api.ipify.org 2>/dev/null
    fi
}

LOCAL_IP=$(get_local_ip)
PUBLIC_IP=$(get_public_ip)

if [ -n "$LOCAL_IP" ]; then
    print_info "local ip: $LOCAL_IP"
else
    print_warning "could not determine local ip"
fi

if [ -n "$PUBLIC_IP" ]; then
    print_info "public ip: $PUBLIC_IP"
else
    print_warning "could not determine public ip"
fi
