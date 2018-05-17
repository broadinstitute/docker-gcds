#!/bin/bash

usage() {
    PROG=$( basename "$0" )
    echo "usage: ${PROG} <config file>"
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

PREFS_DIR="${DATA_DIR}/.java"
CONFIG_DIR="${DATA_DIR}/configs"

CONFIG_FILE=$( basename "$1" )
CONFIG_PATH="${CONFIG_DIR}/${CONFIG_FILE}"

if [ ! -d "${PREFS_DIR}" ]; then
    echo "Java preferences directory ${PREFS_DIR} not found...exiting"
    exit 3
fi

if [ ! -f "${CONFIG_PATH}" ]; then
    echo "Config file ${CONFIG_PATH} not found...exiting"
    exit 4
fi

if [ "$TERM" != 'dumb' ]; then
    TTY='-it'
fi

if [ ! -w "${DOCKER_SOCKET}" ]; then
    SUDO='sudo'
fi

$SUDO docker run $TTY --rm \
        --hostname gcds \
        -v "${CONFIG_DIR}":/gcds/configs \
        -v "${PREFS_DIR}":/root/.java \
        "${GCDS_IMAGE}" \
        /gcds/encrypt-util -c "/gcds/configs/${CONFIG_FILE}"
