#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../utils/bash/colors.bash"

function get_sysinfo() {
    print_info "System Information"
    print_info "Date: $(date)"
    print_info "--------------------------------------------------------------------------------"
    print_info "Hostname: $(hostname)"
    print_info "--------------------------------------------------------------------------------"
    print_info "Kernel Version: $(uname -r)"
    print_info "--------------------------------------------------------------------------------"
    print_info "Uptime: $(uptime)"
    print_info "--------------------------------------------------------------------------------"
    print_info "File System: $(df -h)"
    print_info "--------------------------------------------------------------------------------"
    print_info "Network Configuration: $(ifconfig)"
    print_info "--------------------------------------------------------------------------------"
    print_info "Environment Variables: $(printenv)"
    print_info "--------------------------------------------------------------------------------"
    print_info "DNS Servers: $(cat /etc/resolv.conf | grep nameserver)"
    print_info "--------------------------------------------------------------------------------"
}

get_sysinfo
