#!/bin/bash

# Get the directory of the current script
script_dir=$(dirname "$BASH_SOURCE")

# Source the common.sh
source "${script_dir}/common.sh"

process_flags "$@"
assign_default_value "PORT" "ESPPORT" "/dev/ttyUSB0"
assign_default_value "BAUD" "ESPBAUD" "921600"
assign_default_value "CHIP" "ESPCHIP" "esp32"

calculate_addresses

firmware_parts=(
    "0x1000:images/bootloader.bin"
    "0x8000:images/partition-table.bin"
    "${APP_ADDR}:images/micropython.bin"
)

if [[ -n "${OTA_ADDR}" && "${OTA_ADDR}" -ne 0 ]]; then
    firmware_parts+=("${OTA_ADDR}:images/ota_data_initial.bin")
fi

firmware_parts+=("${PART_ADDR}:images/sys.img")

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

echo "writing image to port ${PORT} baud = ${BAUD}"

esptool.py -p "${PORT}" -b "${BAUD}" --before default_reset --after hard_reset --chip "${CHIP}" write_flash --flash_mode dio \
   --flash_freq 40m "${firmware_opts[@]}"
