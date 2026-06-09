#!/bin/bash
# makes sure the folder containing the script will be the root folder
cd "$(dirname "$0")" || exit

source "../utils/bash/colors.bash"

# Edited by: Paulo José de Oliveira Salgado
# Email: paulo@technosoftware.com.br
#
# Depending on your docker configuration, root might be required. If your nrpe user has rights
# to talk to the docker daemon, then root is not required. This is why root privileges are not
# checked.
#
# The script checks if a container is running.
#   OK - running
#   WARNING - restarting
#   CRITICAL - stopped
#   UNKNOWN - does not exist

function check_docker_container() {
  CONTAINER=$1

  if [ "${CONTAINER}" == "" ]; then
    print_error "3 - UNKNOWN"
    print_error "Container ID or Friendly Name Required"
    print_error "Usage: check_docker_container $0 <container_id_or_friendly_name>"
    exit 3
  fi

  if [ "$(which docker)" == "" ]; then
    print_error "3 - UNKNOWN"
    print_error "Missing docker binary"
    exit 3
  fi

  docker info >/dev/null 2>&1

  if [ $? -ne 0 ]; then
    print_error "3 - UNKNOWN"
    print_error "Unable to talk to the docker daemon"
    exit 3
  fi

  RUNNING=$(docker inspect --format="{{.State.Running}}" "$CONTAINER" 2>/dev/null)

  if [ $? -eq 1 ]; then
    print_error "3 - UNKNOWN"
    print_error "$CONTAINER does not exist."
    exit 3
  fi

  if [ "$RUNNING" == "false" ]; then
    print_info "2 - CRITICAL"
    print_info "$CONTAINER is not running."
    exit 2
  fi

  RESTARTING=$(docker inspect --format="{{.State.Restarting}}" "$CONTAINER")

  if [ "$RESTARTING" == "true" ]; then
    print_warning "1 - WARNING"
    print_warning "$CONTAINER state is restarting."
    exit 1
  fi

  STARTED=$(docker inspect --format="{{.State.StartedAt}}" "$CONTAINER")
  NETWORK=$(docker inspect --format="{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}" "$CONTAINER")

  print_success "0 - RUNNING OK"
  print_success "$CONTAINER is running."
  print_success "-> IP: $NETWORK"
  print_success "Started at: $STARTED"
}

check_docker_container "$1"