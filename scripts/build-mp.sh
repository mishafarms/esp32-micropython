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

WD=$(pwd)

(cd ../micropython/ports/esp32 && make BOARD=WROVER_16M BOARD_VARIANT=OTA_USER &&
 cp build-WROVER_16M-OTA_USER/micropython.bin "${WD}/images" &&
 cp build-WROVER_16M-OTA_USER/partition_table/partition-table.bin "${WD}/images" &&
 cp build-WROVER_16M-OTA_USER/bootloader/bootloader.bin "${WD}/images" &&
 cp build-WROVER_16M-OTA_USER/ota_data_initial.bin "${WD}/images" && cd "${WD}" &&
 PART_ADDR=$(./gen_esp32part.py images/partition-table.bin | grep vfs | awk -F',' '{print $4}') &&
 esptool.py --chip esp32 merge_bin -o images/merged-firmware.bin --flash_mode dio --flash_size 16MB --flash_freq 40m 0x1000 images/bootloader.bin 0x8000 images/partition-table.bin 0x10000 images/micropython.bin 0x510000 images/ota_data_initial.bin "${PART_ADDR}" images/sys.img
)
