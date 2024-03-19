#!/bin/bash
 PART_ADDR=$(./gen_esp32part.py images/partition-table.bin | grep vfs | awk -F',' '{print $4}')
 esptool.py --chip esp32 merge_bin -o images/merged-firmware.bin --flash_mode dio --flash_size 16MB \
 --flash_freq 40m 0x1000 images/bootloader.bin 0x8000 images/partition-table.bin 0x10000 images/micropython.bin \
 0x510000 images/ota_data_initial.bin "${PART_ADDR}" images/sys.img
