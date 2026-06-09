#!/bin/bash

# Open new Terminal tabs from the command line
#
# https://gist.github.com/bobthecow/757788
# Author: Justin Hileman (http://justinhileman.com)
#
# Installation:
#     Add the following function to your `.bashrc` or `.bash_profile`,
#     or save it somewhere (e.g. `~/.tab.bash`) and source it in `.bashrc`
#
# Usage:
#     tab                   Opens the current directory in a new tab
#     tab [PATH]            Open PATH in a new tab
#     tab [CMD]             Open a new tab and execute CMD
#     tab [PATH] [CMD] ...  You can prob'ly guess

# Only for Mac users
[ $(uname -s) != "Darwin" ] && return

function tab() {
    local cmd=""
    local cdto="$PWD"
    local args="$@"

    if [ -d "$1" ]; then
        cdto=$(
            cd "$1"
            pwd
        )
        args="${@:2}"
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
