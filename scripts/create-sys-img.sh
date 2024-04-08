#!/bin/bash

# Get the directory of the current script
script_dir=$(dirname "$BASH_SOURCE")

# Source the common.sh
source "${script_dir}/common.sh"

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

process_flags "$@"
assign_default_value "FILE_SYSTEM_TYPE" "ESPFSTYPE" "LFS"
export ESPFSTYPE="${FILE_SYSTEM_TYPE}"

echo "FILE_SYSTEM_TYPE = ${FILE_SYSTEM_TYPE}"

SYS_IMG="images/sys.img"

if ! calculate_addresses; then
    echo "calculate_addresses function failed."
    # handle the error or exit
    exit 1
fi

# Check if the command was successful
if [ -f "$SYS_IMG" ]; then
  # Get the size of the file using wc (word count) utility in bytes
  file_size_bytes=$(wc -c <"$SYS_IMG")

  if are_sizes_same "${file_size_bytes}" "${VFS_SIZE}" ; then
    echo "File sizes are the same."
  else
    echo "File sizes are different, we need to deal with it"
    # rm the file
    rm "${SYS_IMG}"
    dd if=/dev/zero of="${SYS_IMG}" bs=1 count="${VFS_SIZE}"
  fi
fi


# Choose the file system based on the FILE_SYSTEM_TYPE
if [[ "${FILE_SYSTEM_TYPE^^}" == "FAT" ]] ; then
  echo "Making a FAT file system."
  mkfs.fat -F 12 -f 1 -S 4096 -r 512 -s 1 -n 'ROOT' "${SYS_IMG}"
elif [[ "${FILE_SYSTEM_TYPE^^}" == "LFS" ]] ; then
  echo "Making an LFS file system"
  losetup -d /dev/loop0 2> /dev/null
  losetup /dev/loop0 ${SYS_IMG}
  lfs --block_size=4096 --format /dev/loop0
  losetup -d /dev/loop0
else
  echo 'Invalid argument. You need to specify either "FAT" or "LFS" with the -f or defaults to LFS'
  exit 1
fi

exit 0
