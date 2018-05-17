#!/bin/bash

usage() {
    PROG=$(basename "$0")
    echo "usage: ${PROG}"
}

SCRIPT_DIR="$( cd -P "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
# shellcheck source=/dev/null
source "${SCRIPT_DIR}/config.sh"

if [ -z "${DISPLAY}" ]; then
    echo "DISPLAY variable not set.  Please make sure X11 forwarding is on"
    exit 1
fi

if [ ! -f "${XAUTHORITY}" ]; then
    echo "The Xauthority file '${XAUTHORITY}'  does not exist"
    echo "Try connecting correctly using SSH with X11 Forwarding"
    exit 2
fi

if [ -z "${DATA_DIR}" ]; then
    echo "DATA_DIR configuration variable was not set.  Exiting!"
    exit 3
fi

PREFS_DIR="${DATA_DIR}/.java"
CONFIG_DIR="${DATA_DIR}/configs"

if [ ! -d "${PREFS_DIR}" ]; then
    echo "Java preferences directory ${PREFS_DIR} not found...exiting"
    exit 4
fi

if [ ! -d "${CONFIG_DIR}" ]; then
    echo "Config directory ${CONFIG_DIR} not found...exiting"
    exit 5
fi

if [ "$TERM" != "dumb" ]; then
    TTY='-it'
fi

if [ ! -w "${DOCKER_SOCKET}" ]; then
    SUDO='sudo'
fi

$SUDO docker run $TTY --rm \
        -e DISPLAY="${DISPLAY}" \
        -v "${XAUTHORITY}:/root/.Xauthority" \
        -v "${CONFIG_DIR}:/gcds/configs" \
        -v "${PREFS_DIR}:/root/.java" \
        --net=host \
        "${GCDS_IMAGE}" \
        /gcds/config-manager
