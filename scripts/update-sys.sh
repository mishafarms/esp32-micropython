#!/bin/bash

LINUX="linux-gnu"
DARWIN="darwin*"

set_os_type() {
    if [[ "$OSTYPE" == "$LINUX" ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "$DARWIN" ]]; then
        echo "osx"
    else
        echo "Invalid OS"
        exit 1
    fi
}

run_commands() {
    OS_TYPE=$(set_os_type)
    echo "OS type is: $OS_TYPE"

    yarn
    yarn run mount-sys-"$OS_TYPE"
    yarn run bundle-otto
    yarn run umount-sys-"$OS_TYPE"
    yarn run flash-sys
}

run_commands
