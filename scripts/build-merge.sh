#!/bin/bash

# Get the directory of the current script
script_dir=$(dirname "$BASH_SOURCE")

# Source the common.sh
source "${script_dir}/common.sh"

calculate_addresses

firmware_parts=(
    "0x1000:images/bootloader.bin"
    "0x8000:images/partition-table.bin"
    "${APP_ADDR}:images/micropython.bin"
)

if [[ -n "${OTA_D_ADDR}" && "${OTA_D_ADDR}" -ne 0 ]]; then
    firmware_parts+=("${OTA_D_ADDR}:images/ota_data_initial.bin")
fi

firmware_parts+=("${VFS_ADDR}:images/sys.img")

firmware_opts=()
for part in "${firmware_parts[@]}"; do
    IFS=":" read -r address image <<< "${part}"
    if [[ ! -f ${image} ]]; then
        echo "No such file: ${image}"
        exit 1
    else
        firmware_opts+=("${address}" "${image}")
    fi
done

esptool.py --chip "${CHIP}" merge_bin -o images/merged-firmware.bin --flash_mode dio --flash_size 16MB \
   --flash_freq 40m "${firmware_opts[@]}"
