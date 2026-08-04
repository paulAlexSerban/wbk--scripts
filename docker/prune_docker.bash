#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../utils/bash/colors.bash"

if ! command -v docker >/dev/null 2>&1; then
    print_error "docker not found"
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    print_error "docker daemon not reachable"
    exit 1
fi

print_warning "This will run: docker system prune -f"
print_info "Remove unused containers, networks, and dangling images."
read -r -p "Continue? [y/N] " reply
case "$reply" in
    [yY]|[yY][eE][sS]) ;;
    *)
        print_info "aborted"
        exit 0
        ;;
esac

print_info "pruning…"
if docker system prune -f; then
    print_success "docker prune complete"
else
    print_error "docker prune failed"
    exit 1
fi
