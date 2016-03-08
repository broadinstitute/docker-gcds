#!/bin/sh

usage() {
    PROG="$(basename $0)"
    echo "usage: ${PROG} <config dir>"
}

SCRIPT_DIR="$( cd -P "$( dirname "$BASH_SOURCE[0]" )" && pwd )"
source "${SCRIPT_DIR}/config.sh"

if [ -z "$1" ];
then
    usage
    exit 1
fi

if [ -z "${DATA_DIR}" ]; then
    echo "DATA_DIR configuration variable was not set.  Exiting!"
    exit 2
fi

if [ -z "${LOG_DIR}" ]; then
    echo "LOG_DIR configuration variable was not set.  Exiting!"
    exit 3
fi

PREFS_DIR="${DATA_DIR}/.java"
CONFIG_DIR="${DATA_DIR}/configs"

if [ ! -d "${PREFS_DIR}" ];
then
    echo "Java preferences directory ${PREFS_DIR} not found...exiting"
    exit 2
fi

if [ ! -d "${CONFIG_DIR}" ];
then
    echo "Config directory ${CONFIG_DIR} not found...exiting"
    exit 3
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
       -v $SCRIPT_DIR:/usr/src \
       $GADS_IMAGE \
       /bin/bash
       #/usr/src/GADSrunner.py $CONFIG_FILE $@
