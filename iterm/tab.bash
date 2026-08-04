#!/bin/bash

# Open new Terminal tabs from the command line
#
# https://gist.github.com/bobthecow/757788
# Author: Justin Hileman (http://justinhileman.com)
#
# Installation:
#     Source this file from `.bashrc` / `.zshrc` (macOS only).
#
# Usage:
#     tab                   Opens the current directory in a new tab
#     tab [PATH]            Open PATH in a new tab
#     tab [CMD]             Open a new tab and execute CMD
#     tab [PATH] [CMD] ...  You can prob'ly guess

if [ -n "${BASH_SOURCE[0]:-}" ]; then
    # shellcheck disable=SC1091
    source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../utils/bash/is_macos.bash"
fi

if declare -f is_macos >/dev/null 2>&1; then
    is_macos || return 0 2>/dev/null || exit 0
else
    [[ "$(uname)" == "Darwin" ]] || return 0 2>/dev/null || exit 0
fi

function tab() {
    local cmd=""
    local cdto="$PWD"
    local args="$*"

    if [ -d "$1" ]; then
        cdto=$(
            cd "$1"
            pwd
        )
        args="${*:2}"
    fi

    if [ -n "$args" ]; then
        cmd="; $args"
    fi

    case "$TERM_PROGRAM" in
    'iTerm.app')
        osascript &>/dev/null <<EOF
        tell application "iTerm"
            tell current session of first window
                set newSession to (split vertically with default profile)
                tell newSession
                    write text "cd \"$cdto\"$cmd"
                end tell
            end tell
        end tell
EOF
        ;;
    'Apple_Terminal')
        osascript &>/dev/null -e "
        tell application \"Terminal\"
            activate
            tell application \"System Events\" to keystroke \"t\" using command down
            repeat while contents of selected tab of window 1 starts with linefeed
                delay 0.01
            end repeat
            do script \"cd \\\"$cdto\\\"$cmd\" in window 1
        end tell
    "
        ;;
    esac
}
