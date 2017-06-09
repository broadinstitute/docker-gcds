#!/bin/sh

SCRIPT_DIR="$( cd -P "$( dirname "$BASH_SOURCE[0]" )" && pwd )"
source "${SCRIPT_DIR}/config.sh"

if [ "$TERM" != "dumb" ];
then
    TTY='-it'
fi

if [ ! -w "${DOCKER_SOCKET}" ];
then
    SUDO='sudo'
fi

$SUDO docker run $TTY --rm \
       $GADS_IMAGE \
       /gcds/checkforupdate
