#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../utils/bash/colors.bash"

# Function to update kubeconfig for all EKS clusters in the current AWS account
function update_kubeconfig() {
    # Get AWS account ID
    ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')
    if [ $? -ne 0 ]; then
        print_error "Failed to get AWS account ID. Please check your AWS credentials."
        exit 1
    fi

    print_info "Updating kubeconfig for all EKS clusters in account $ACCOUNT_ID"

    # List all EKS clusters and update kubeconfig for each
    CLUSTERS=$(aws eks list-clusters --output text --query 'clusters')
    if [ $? -ne 0 ]; then
        print_error "Failed to list EKS clusters. Please check your AWS permissions."
        exit 1
    fi

    if [ -z "$CLUSTERS" ]; then
        print_error "No EKS clusters found in account $ACCOUNT_ID"
        exit 0
    fi

        # Convert space-separated cluster names to array
    CLUSTER_ARRAY=($(echo "$CLUSTERS" | tr -s ' ' '\n'))

    # Iterate over each cluster name in the list
    for CLUSTER in $CLUSTER_ARRAY; do
        print_info "Updating kubeconfig for cluster: $CLUSTER"
        aws eks update-kubeconfig --name "$CLUSTER"
        if [ $? -ne 0 ]; then
            print_error "Failed to update kubeconfig for cluster: $CLUSTER"
        else
            print_success "Successfully updated kubeconfig for cluster: $CLUSTER"
        fi
    done
}

update_kubeconfig