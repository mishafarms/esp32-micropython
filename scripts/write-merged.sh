#!/bin/bash

# Get the directory of the current script
script_dir=$(dirname "$BASH_SOURCE")

# Source the common.sh
source "${script_dir}/common.sh"

process_flags "$@"
assign_default_value "PORT" "ESPPORT" "/dev/ttyUSB0"
assign_default_value "BAUD" "ESPBAUD" "921600"
assign_default_value "CHIP" "ESPCHIP" "esp32"

echo "writing merged image to port ${PORT} baud = ${BAUD}"
esptool.py -p "${PORT}" -b "${BAUD}" --before default_reset --after hard_reset --chip "${CHIP}" write_flash --flash_mode dio --flash_size 16MB --flash_freq 40m 0x0000 images/merged-firmware.bin


