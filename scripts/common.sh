# common.sh

process_flags() {
    local HELP_MSG=$1
    shift  # Shift arguments so that getopts works on command-line arguments

    while getopts b:c:f:m:p:v:s:h flag
    do
        case "${flag}" in
            b) BAUD=${OPTARG};;
            c) CHIP=${OPTARG};;
            f) FILE_SYSTEM_TYPE=${OPTARG};;
            m) BOARD=${OPTARG};;
            p) PORT=${OPTARG};;
            v) BOARD_VARIANT=${OPTARG};;
            s) SECTIONS=${OPTARG} HASH_SPACE_SEPARATED=1;;
            h) echo "$HELP_MSG"; exit 0;;
            *) echo "$HELP_MSG"; exit 1;;
        esac
    done
}

function assign_default_value {
    local value_var="${1}"
    local default_var="${2}"
    local default_val="${3}"

    if [[ -z "${!value_var}" ]]; then
        if [[ -z "${!default_var}" ]]; then
            readonly "${value_var}=${default_val}"
        else
            readonly "${value_var}=${!default_var}"
        fi
    fi
}

calculate_addresses() {
    APP_ADDR=0
    APP_SIZE=0
    OTA_D_ADDR=0
    OTA_D_SIZE=0
    VFS_ADDR=0
    VFS_SIZE=0

    if ! OUTPUT=$(./gen_esp32part.py images/partition-table.bin); then
        echo "gen_esp32part.py failed."
        return 1
    fi

    APP_ADDR=$(echo "${OUTPUT}" | awk -F',' '/app/ {print $4}' | head -1)
    APP_SIZE=$(echo "${OUTPUT}" | awk -F',' '/app/ {print $5}' | head -1)

    OTA_D_ADDR=$(echo "${OUTPUT}" | awk -F',' '/otadata/ {print $4}' | head -1)
    OTA_D_SIZE=$(echo "${OUTPUT}" | awk -F',' '/otadata/ {print $5}' | head -1)

    VFS_ADDR=$(echo "${OUTPUT}" | awk -F',' '/vfs/ {print $4}' | head -1)
    VFS_SIZE=$(echo "${OUTPUT}" | awk -F',' '/vfs/ {print $5}' | head -1)
    return 0
}
