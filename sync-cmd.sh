#!/bin/bash

usage() {
    PROG=$( basename "$0" )
    echo "usage: ${PROG} <config file> [GCDS options]"
}

SCRIPT_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/config.sh"

if [ -z "$1" ]; then
    usage
    exit 1
fi

if [ -z "${DATA_DIR}" ]; then
    echo 'DATA_DIR configuration variable was not set.  Exiting!'
    exit 2
fi

if [ -z "${LOG_DIR}" ]; then
    echo 'LOG_DIR configuration variable was not set.  Exiting!'
    exit 3
fi

PREFS_DIR="${DATA_DIR}/.java"
CONFIG_DIR="${DATA_DIR}/configs"
STATE_DIR="${DATA_DIR}/state"

CONFIG_FILE=$( basename "$1" )
CONFIG_PATH="${CONFIG_DIR}/${CONFIG_FILE}"

# Tear the config file name off so we can pass the rest to GCDS
shift

if [ ! -d "${PREFS_DIR}" ]; then
    echo "Java preferences directory ${PREFS_DIR} not found...exiting"
    exit 4
fi

if [ ! -d "${LOG_DIR}" ]; then
    echo "Log directory ${LOG_DIR} not found...exiting"
    exit 5
fi

if [ ! -f "${CONFIG_PATH}" ]; then
    echo "Config file ${CONFIG_PATH} not found...exiting"
    exit 6
fi

if [ "$TERM" != 'dumb' ]; then
    TTY='-it'
fi

if [ ! -w "${DOCKER_SOCKET}" ]; then
    SUDO='sudo'
fi

# shellcheck disable=SC2068
$SUDO docker run $TTY --rm \
        --hostname gcds \
        -v "${CONFIG_DIR}":/gcds/configs \
        -v "${STATE_DIR}":/root/syncState \
        -v "${PREFS_DIR}":/root/.java \
        -v "${LOG_DIR}":/var/log/google \
        "${GCDS_IMAGE}" \
        /gcds/sync-cmd -c "/gcds/configs/${CONFIG_FILE}" $@
