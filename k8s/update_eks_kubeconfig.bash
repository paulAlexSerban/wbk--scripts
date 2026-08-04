#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../utils/bash/colors.bash"

if ! command -v aws >/dev/null 2>&1; then
    print_error "aws CLI not found"
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')
if [ $? -ne 0 ] || [ -z "$ACCOUNT_ID" ]; then
    print_error "Failed to get AWS account ID. Check your AWS credentials."
    exit 1
fi

print_info "Updating kubeconfig for all EKS clusters in account $ACCOUNT_ID"

CLUSTERS=()
while IFS= read -r cluster; do
    [ -n "$cluster" ] && CLUSTERS+=("$cluster")
done < <(aws eks list-clusters --output text --query 'clusters[]' 2>/dev/null)

if [ ${#CLUSTERS[@]} -eq 0 ]; then
    print_error "No EKS clusters found in account $ACCOUNT_ID"
    exit 1
fi

for CLUSTER in "${CLUSTERS[@]}"; do
    print_info "Updating kubeconfig for cluster: $CLUSTER"
    if aws eks update-kubeconfig --name "$CLUSTER"; then
        print_success "Updated kubeconfig for cluster: $CLUSTER"
    else
        print_error "Failed to update kubeconfig for cluster: $CLUSTER"
    fi
done
