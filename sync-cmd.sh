#!/bin/sh

usage() {
    PROG="$(basename $0)"
    echo "usage: ${PROG} <config file> [GADS options]"
}

SCRIPT_DIR="$( cd -P "$( dirname "$BASH_SOURCE[0]" )" && pwd )"
source "${SCRIPT_DIR}/config.sh"

if [ -z "$1" ];
then
    usage
    exit 1
fi

# Tear the config file name off so we can pass the rest to GADS
shift

PREFS_DIR="${SCRIPT_DIR}/.java"

CONFIG_DIR="$( cd -P "$( dirname "$1" )" && pwd )"
CONFIG_FILE="$( basename $1 )"
CONFIG_PATH="${CONFIG_DIR}/${CONFIG_FILE}"

if [ ! -d "${PREFS_DIR}" ];
then
    echo "Java preferences directory ${PREFS_DIR} not found...exiting"
    exit 3
fi

if [ ! -f "${CONFIG_PATH}" ];
then
    echo "Config file ${CONFIG_PATH} not found...exiting"
    exit 4
fi

if [ "$TERM" != "dumb" ];
then
    TTY='-it'
fi

if [ ! -w "${DOCKER_SOCKET}" ];
then
    SUDO='sudo'
fi

$SUDO docker run $TTY --rm \
       --name gads \
       --hostname gads \
       -v $CONFIG_DIR:/gads/configs \
       -v $PREFS_DIR:/root/.java \
       $GADS_IMAGE \
      /gads/upgrade-config -c /gads/configs/$CONFIG_FILE $@
