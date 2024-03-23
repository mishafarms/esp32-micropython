#!/bin/bash

while getopts p:b:c:m:v: flag
	do
	    case "${flag}" in
	        c) CHIP=${OPTARG};;
	        p) PORT=${OPTARG};;
	        b) BAUD=${OPTARG};;
	        m) BOARD=${OPTARG};;
	        v) BOARD_VARIANT=${OPTARG};;
	        *) echo "bad flag -${flag}"
	    esac
	done
if [[ -z "${PORT}" ]]; then
	if [[ -z "${ESPPORT}" ]]; then
		PORT="/dev/ttyUSB0"
	else
		PORT="${ESPPORT}"
	fi
fi

if [[ -z "${BAUD}" ]]; then
	if [[ -z "${ESPBAUD}" ]]; then
		BAUD="921600"
	else
		BAUD="${ESPBAUD}"
	fi
fi

if [[ -z "${CHIP}" ]]; then
	if [[ -z "${ESPCHIP}" ]]; then
		CHIP="esp32"
	else
		CHIP="${ESPCHIP}"
	fi
fi

if [[ -z "${BOARD}" ]]; then
  BOARD="WROVER_16M"
fi

if [[ -z "${BOARD_VARIANT}" ]]; then
  TWEEN=""
else
  TWEEN="-"
fi

WD=$(pwd)

( cd ../micropython && make -C mpy-cross && \
  cd ports/esp32 && make submodules && make BOARD="${BOARD}" BOARD_VARIANT="${BOARD_VARIANT}" &&
  cp build-"${BOARD}"-"${BOARD_VARIANT}"/micropython.bin "${WD}/images" &&
  cp build-"${BOARD}"-"${BOARD_VARIANT}"/partition_table/partition-table.bin "${WD}/images" &&
  cp build-"${BOARD}"-"${BOARD_VARIANT}"/bootloader/bootloader.bin "${WD}/images" )
