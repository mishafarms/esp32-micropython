#!/bin/bash

function are_sizes_same {
  size_str1="$1"
  size_str2="$2"

  size1_bytes=$(convert_to_bytes "$size_str1")
  size2_bytes=$(convert_to_bytes "$size_str2")

  if [ "$size1_bytes" -eq "$size2_bytes" ]; then
    return 0  # sizes are equal, return true
  else
    return 1  # sizes are not equal, return false
  fi
}

function convert_to_bytes {
  size_str="$1"

  # Determine the multiplier based on the suffix
  if [[ $size_str == *'M'* ]]; then
    multiplier=1048576  # 1024^2
  elif [[ $size_str == *'K'* ]]; then
    multiplier=1024
  else
    multiplier=1
  fi

  # Remove the suffix (if any) to get the numeric part
  size=${size_str//[!0-9]/}

  # Calculate the size in bytes
  size_bytes=$((size * multiplier))

  echo $size_bytes
}

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

#esptool.py --chip $CHIP -b 115200 -p $PORT read_flash 0x8000 0xc00 ptable.img

#GEN_STR=$(./gen_esp32part.py ./ptable.img)
GEN_STR=$(./gen_esp32part.py images/partition-table.bin)
status=$?

SYS_IMG="images/sys.img"

# Check if the command was successful
if [ $status -eq 0 ]; then
    PART_SIZE=$(echo -e "${GEN_STR}" | grep vfs | awk -F',' '{print $5}')
    # see if there is a file called images/sys.img and if there is
    # how big is it?
    if [ -f "$SYS_IMG" ]; then
      # Get the size of the file using wc (word count) utility in bytes
      file_size_bytes=$(wc -c <"$SYS_IMG")

      if are_sizes_same "${file_size_bytes}" "${PART_SIZE}" ; then
        echo "File sizes are the same."
        exit 0
      else
        echo "File sizes are different, we need to deal with it"
        # rm the file
        rm "${SYS_IMG}"
      fi
    fi

    dd if=/dev/zero of="${SYS_IMG}" bs=1 count=0 count="${PART_SIZE}"
    mkfs.fat -F 12 -f 1 -S 4096 -r 512 -s 1 -n 'ROOT' "${SYS_IMG}"
    exit 0
else
    echo "Command failed with status $status."
    exit 1
fi
