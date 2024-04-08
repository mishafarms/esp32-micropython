#!/usr/bin/env bash

# Get the directory of the current script
script_dir=$(dirname "$BASH_SOURCE")

# Source the common.sh
source "${script_dir}/common.sh"

SCRIPT_NAME="$(basename "$0")"

HELP_MSG="Usage: $SCRIPT_NAME [options]

The options are:
    -b <baud rate>
    -c <chip type>
    -f <LFS|FAT>
    -p <port>
    -h                prints this help information

defaults to LFS with no -f given"

process_flags "$HELP_MSG" "$@"
assign_default_value "PORT" "ESPPORT" "/dev/ttyUSB0"
assign_default_value "BAUD" "ESPBAUD" "921600"
assign_default_value "CHIP" "ESPCHIP" "esp32"
assign_default_value "FILE_SYSTEM_TYPE" "ESPFSTYPE" "LFS"

# to allow yarn to make the calls and still use the same port, baudrate and chip
export ESPPORT="$PORT"
export ESPBAUD="$BAUD"
export ESPCHIP="$CHIP"
export ESPFSTYPE="$FILE_SYSTEM_TYPE"

# Function for yarn build
yarn_build() {
    cd "$1" || exit 2
    yarn
    yarn run build
}

# Build Projects
(yarn_build "../edublocks-micropython")
(yarn_build "panel")

run_commands() {
    set -e
    yarn
    yarn run build-mp
    yarn run create-sys-img
    yarn run mount-sys-"${FILE_SYSTEM_TYPE,,}"
    yarn run bundle-otto
    yarn run umount-sys-"${FILE_SYSTEM_TYPE,,}"
    yarn run flash
    set +e
}

run_commands
