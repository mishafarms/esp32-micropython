#!/bin/bash

# Get the directory of the current script
script_dir=$(dirname "$BASH_SOURCE")

# Source the common.sh
source "${script_dir}/common.sh"

function perform_build_operations() {
  local board=$1
  local board_variant=$2
  local tween=$3
  local wd=$4

  cd ../micropython && make -C mpy-cross
  cd ports/esp32 && make submodules && make BOARD="${board}" BOARD_VARIANT="${board_variant}"

  cp -v "build-${board}${tween}${board_variant}/micropython.bin" "${wd}/images"
  cp -v "build-${board}${tween}${board_variant}/partition_table/partition-table.bin" "${wd}/images"
  cp -v "build-${board}${tween}${board_variant}/bootloader/bootloader.bin" "${wd}/images"

  if [[ -e "build-${board}${tween}${board_variant}/ota_data_initial.bin" ]]; then
    cp -v "build-${board}${tween}${board_variant}/ota_data_initial.bin" "${wd}/images"
  else
    rm -f "${wd}/images/ota_data_initial.bin"
  fi
}

process_flags "$@"

assign_default_value "PORT" "/dev/ttyUSB0" "${PORT}"
assign_default_value "BAUD" "921600" "${BAUD}"
assign_default_value "CHIP" "esp32" "${CHIP}"
assign_default_value "BOARD" "WROVER_16M" "${BOARD}"

TWEEN=""
if [[ -n "${BOARD_VARIANT}" ]]; then
  TWEEN="-"
fi

WD=$(pwd)

# Enclosed in parentheses to run it in a subshell
# It will not change the current directory of the parent shell
(perform_build_operations "${BOARD}" "${BOARD_VARIANT}" "${TWEEN}" "${WD}")
