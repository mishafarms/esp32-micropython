#!/bin/bash

# Function for yarn build
yarn_build() {
  cd "$1" || exit 2
  yarn
  yarn run build
}

# Identify OS
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    OS=linux
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS=osx
else
    echo 'Invalid OS'
    exit 1
fi

# Build Projects
(yarn_build "../edublocks-micropython")
(yarn_build "panel")

# Execute remaining commands
yarn
yarn run build-mp
yarn run create-sys-img
yarn run mount-sys-$OS
yarn run bundle-otto
yarn run umount-sys-$OS
yarn run flash-micropython
yarn run flash-sys
