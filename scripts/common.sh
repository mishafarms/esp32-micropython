# common.sh

function process_flags {
    while getopts b:c:f:m:p:v: flag
    do
        case "${flag}" in
            b) BAUD=${OPTARG};;
            c) CHIP=${OPTARG};;
            f) FILE_SYSTEM_TYPE=${OPTARG};;
            m) BOARD=${OPTARG};;
            p) PORT=${OPTARG};;
            v) BOARD_VARIANT=${OPTARG};;
            *) echo "Invalid flag -${flag}"
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
    OTA_ADDR=0
    OTA_SIZE=0
    PART_ADDR=0
    PART_SIZE=0

    if ! OUTPUT=$(./gen_esp32part.py images/partition-table.bin); then
        echo "gen_esp32part.py failed."
        return 1
    fi

    APP_ADDR=$(echo "${OUTPUT}" | awk -F',' '/app/ {print $4}' | head -1)
    APP_SIZE=$(echo "${OUTPUT}" | awk -F',' '/app/ {print $5}' | head -1)

    OTA_ADDR=$(echo "${OUTPUT}" | awk -F',' '/otadata/ {print $4}' | head -1)
    OTA_SIZE=$(echo "${OUTPUT}" | awk -F',' '/otadata/ {print $5}' | head -1)

    PART_ADDR=$(echo "${OUTPUT}" | awk -F',' '/vfs/ {print $4}' | head -1)
    PART_SIZE=$(echo "${OUTPUT}" | awk -F',' '/vfs/ {print $5}' | head -1)
    return 0
}
