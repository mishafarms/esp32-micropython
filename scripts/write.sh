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
    -p <port>
    -s <sections>     comma-separated list to identify the partitions to flash
    -h                prints this help information

If no sections are provided to -s, all sections will be flashed.
Available sections are: bootloader, partition-table, app, otadata, vfs."

process_flags "$HELP_MSG" "$@"

assign_default_value "PORT" "ESPPORT" "/dev/ttyUSB0"
assign_default_value "BAUD" "ESPBAUD" "921600"
assign_default_value "CHIP" "ESPCHIP" "esp32"
assign_default_value "SECTIONS" "SECTIONS" "bootloader,partition-table,app,otadata,vfs"

calculate_addresses

# Assign our partition addresses to respective sections
declare -A partitions
partitions["bootloader"]=0x1000
partitions["partition-table"]=0x8000
partitions["app"]=$APP_ADDR
partitions["otadata"]=$OTA_D_ADDR
partitions["vfs"]=$VFS_ADDR

# Map the section names to their file names
declare -A file_names
file_names["bootloader"]="bootloader.bin"
file_names["partition-table"]="partition-table.bin"
file_names["app"]="micropython.bin"
file_names["otadata"]="ota_data_initial.bin"
file_names["vfs"]="sys.img"

firmware_parts=()
IFS=',' read -ra ADDR <<<"$SECTIONS"
for section in "${ADDR[@]}"; do
    # Check if the key exists in the dictionary
    if [[ ! -v partitions[$section] ]]; then
        echo "Invalid section: $section"
        exit 1
    fi

    # else, section is valid, check if the address is non-zero and non-empty
    if [[ -n "${partitions[$section]}" && "${partitions[$section]}" -ne 0 ]]; then
        # add to flash options
        firmware_parts+=("${partitions[$section]}:images/${file_names[$section]}")
    else
        echo "Skipping section $section as there was no partition for it"
    fi
done

# If firmware_parts is empty, exit with status code 0
if [ ${#firmware_parts[@]} -eq 0 ]; then
    echo "No firmware parts to process. Exiting..."
    exit 0
fi

firmware_opts=()
for part in "${firmware_parts[@]}"; do
    IFS=":" read -r address image <<<"${part}"
    if [[ ! -f ${image} ]]; then
        echo "No such file: ${image}"
        exit 1
    else
        firmware_opts+=("${address}" "${image}")
    fi
done

echo "writing image to port ${PORT} baud = ${BAUD}"

esptool.py -p "${PORT}" -b "${BAUD}" --before default_reset --after hard_reset --chip "${CHIP}" write_flash --flash_mode dio \
    --flash_freq 40m "${firmware_opts[@]}"
