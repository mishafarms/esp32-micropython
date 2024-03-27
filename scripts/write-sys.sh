#!/bin/bash

# Get the directory of the current script
script_dir=$(dirname "$BASH_SOURCE")

# Source the common.sh
source "${script_dir}/common.sh"

process_flags "$@"
assign_default_value "PORT" "ESPPORT" "/dev/ttyUSB0"
assign_default_value "BAUD" "ESPBAUD" "921600"
assign_default_value "CHIP" "ESPCHIP" "esp32"

if ! calculate_addresses; then
  echo "calculate_addresses function failed."
  # handle the error or exit
  exit 1
elif [ "$PART_ADDR" -eq 0 ]; then
  echo "Didn't find an vfs partition address"
  exit 1
fi

echo "writing to port ${PORT} baud = ${BAUD} address = ${PART_ADDR}"
esptool.py --chip "${CHIP}" -b "${BAUD}" -p "${PORT}" write_flash -z "${PART_ADDR}" images/sys.img
