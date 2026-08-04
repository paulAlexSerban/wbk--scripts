#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../utils/bash/colors.bash"

if ! command -v kubectl >/dev/null 2>&1; then
    print_error "kubectl not found"
    exit 1
fi

CONTEXT=$(kubectl config current-context 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$CONTEXT" ]; then
    print_error "no current kubectl context"
    exit 1
fi

NAMESPACE=$(kubectl config view --minify --output 'jsonpath={..namespace}' 2>/dev/null)
NAMESPACE="${NAMESPACE:-default}"

print_info "context: $CONTEXT"
print_info "namespace: $NAMESPACE"
print_info "cluster details:"
kubectl config view --minify
