#!/bin/bash

while getopts p:b:c: flag
	do
	    case "${flag}" in
	        c) CHIP=${OPTARG};;
	        p) PORT=${OPTARG};;
	        b) BAUD=${OPTARG};;
	        *) echo "bad flag -${flag}"
	    esac
	done
if [[ -z "$PORT" ]]; then
	if [[ -z "${ESPPORT}" ]]; then
		PORT="/dev/ttyUSB0"
	else
		PORT="${ESPPORT}"
	fi
fi

if [[ -z "$BAUD" ]]; then
	if [[ -z "${ESPBAUD}" ]]; then
		BAUD="921600"
	else
		BAUD="${ESPBAUD}"
	fi
fi
 
if [[ -z "$CHIP" ]]; then
	if [[ -z "${ESPCHIP}" ]]; then
		CHIP="esp32"
	else
		CHIP="${ESPCHIP}"
	fi
fi
 
echo "writing merged image to port ${PORT} baud = ${BAUD}"
esptool.py -p "${PORT}" -b "${BAUD}" --before default_reset --after hard_reset --chip esp32 write_flash --flash_mode dio --flash_size 16MB --flash_freq 40m 0x0000 images/merged-firmware.bin


