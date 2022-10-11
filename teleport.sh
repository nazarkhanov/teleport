#!/bin/bash

TELEPORT_CONFIG="$HOME/.teleportrc"

trap clean SIGINT SIGTERM ERR EXIT

main() {
    touch "$TELEPORT_CONFIG"

    # check for help option
    local args=("$@")
    while :; do
    case "${1-}" in
        -h|--help)
            helpCmd; return;;
        "") break;;
    esac
    shift
    done

    # handle subcommands
	set -- "${args[@]}"
    case "${1-}" in
        add) addCmd "${@:2}"; return;;
        rm) rmCmd "${@:2}"; return;;
        ls) lsCmd; return;;
        *) stdCmd "${@}"; return;;
    esac
}

clean() {
  trap - SIGINT SIGTERM ERR EXIT
  unset TELEPORT_CONFIG
  unset TELEPORT_USAGE
}

stdCmd() {
    # handle empty arguments case
    if [ "$#" == 0 ]; then
        echo "error: no arguments provided"
        return 1
    fi

    local path=""
    local index=$(grep -E -i -m 1 "[ ,]$1" "$TELEPORT_CONFIG")

    # if record exist
    if [ "$index" != "" ]; then
        path=$(echo "$index" | cut -d ' ' -f1)
    fi

    if [ "$path" == "" ]; then
        text="$1"
        regexp=""

        for (( i=0; i<${#text}; i++ )); do
            regexp="${regexp}${text:$i:1}+[a-zA-Z0-9_.-]*"
        done

        regexp="${regexp}( |$)"
        index=$(grep -E -i -m 1 "$regexp" "$TELEPORT_CONFIG")
    fi

    # if record doesn't exist
    if [ "$index" == "" ]; then
        return
    fi

    path=$(echo "$index" | cut -d ' ' -f1)
    cd "$path"
}

addCmd() {
    # handle empty arguments case
    if [ "$#" == 0 ]; then
        echo "error: no arguments provided"
        return 1
    fi

    local tags=""

    # if tags provided, remember them
    if [ "${2-}" != "" ]; then
        tags="$2"
    fi

    local path=$(abspath "$1")
    local index=$(grep -E -m 1 "$path " "$TELEPORT_CONFIG")

    # if record doesn't exist
    if [ "$index" == "" ]; then
        # create new index
        echo "$path $tags" >> "$TELEPORT_CONFIG"
        return
    fi

    if [ "$tags" == "" ]; then
        return
    fi

    # edit existing index
    local index_=($(echo "$index" | tr ' ' '\n'))

    if [ "${index_[1]}" != "" ]; then
        tags="${index_[1]},$tags"
    fi

    # replace index
    sed -i "s:$index:$path $tags:" "$TELEPORT_CONFIG"
}

rmCmd() {
    # handle empty arguments case
    if [ "$#" == 0 ]; then
        echo "error: no arguments provided"
        return 1
    fi

    for arg in "$@"; do
        # if its a tag
        local index=$(grep -m 1 "[ ,]$arg" "$TELEPORT_CONFIG")

        # if record exist
        if [ "$index" != "" ]; then
            local index_=$(echo "$index" | sed -E -e "s/$arg,?//g")
            sed -i "s:$index:$index_:" "$TELEPORT_CONFIG"
            continue
        fi

        # if its a path
        local path=$(abspath "$arg")
        index=$(grep -E -m 1 "$path " "$TELEPORT_CONFIG")

        # if record exist
        if [ "$index" != "" ]; then
            sed -i "\:$index:d" "$TELEPORT_CONFIG"
        fi
    done
}

lsCmd() {
    less "$TELEPORT_CONFIG"
}

helpCmd() {
    echo "$TELEPORT_USAGE"
}

TELEPORT_USAGE=$(cat <<EOF
Usage: te [<command>] <arg> [<arg> ...] [-h | --help]

Description:

te command allows you to teleport to a directory with various abbreviations

Commands:

add             Add path to index
                Add tags to paths
rm              Remove path from index
                Remove tags from paths
ls              View indexed paths
                and their tags

Options:

-h, --help      Print this help

Examples:

te <path | tag | path abbr>             # teleport to path
te add <path> [<tag> ...]               # add path to index
te rm <path | tag> [<path | tag> ...]   # remove path or tags
te ls                                   # view index
EOF
)

function abspath {
    local target="$1"

    if [ "$target" == "." ]; then
        echo "$(pwd)"
    elif [ "$target" == ".." ]; then
        echo "$(dirname "$(pwd)")"
    else
        echo "$(cd "$(dirname "$1")"; pwd)/$(basename "$1")"
    fi
}

main "$@"
