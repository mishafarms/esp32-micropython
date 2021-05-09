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
		BAUD="115200"
	else
		BAUD="${ESPBAUD}"
	fi
fi
 
if [[ -z "$CHIP" ]]; then
	if [[ -z "${ESPCHIP}" ]]; then
		BAUD="esp32"
	else
		BAUD="${ESPCHIP}"
	fi
fi
 
esptool.py --chip $CHIP -b 115200 -p $PORT read_flash 0x8000 0xc00 ptable.img
PART_ADDR=`./gen_esp32part.py ./ptable.img | grep vfs | awk -F',' '{print $4}'`
rm ptable.img
echo "writing to port " ${PORT} " baud = " ${BAUD} " address = " ${PART_ADDR}
esptool.py --chip $CHIP -b ${BAUD} -p ${PORT} write_flash -z ${PART_ADDR} images/sys.img
