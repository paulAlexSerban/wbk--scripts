#!/bin/bash
export NC='\033[0m' # no color
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export BLUE='\033[0;34m'
export YELLOW='\033[0;33m'

print_info() {
    echo -e "${BLUE}[ INFO ]${NC} $*"
}

print_success() {
    echo -e "${GREEN}[ SUCCESS ]${NC} $*"
}

print_warning() {
    echo -e "${YELLOW}[ WARNING ]${NC} $*"
}

print_error() {
    echo -e "${RED}[ ERROR ]${NC} $*"
}
