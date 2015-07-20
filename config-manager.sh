#!/bin/sh

SCRIPT_DIR="$( cd -P "$( dirname "$BASH_SOURCE[0]" )" && pwd )"
source "${SCRIPT_DIR}/config.sh"

if [ -z "${DISPLAY}" ];
then
    echo "DISPLAY variable not set.  Please make sure X11 forwarding is on"
    exit 1
fi

if [ ! -f "${XAUTHORITY}" ];
then
    echo "The Xauthority file `${XAUTHORITY}`  does not exist"
    echo "Try connecting correctly using SSH with X11 Forwarding"
    exit 2
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
       -e DISPLAY=$DISPLAY \
       -v $XAUTHORITY:/root/.Xauthority \
       --net=host \
       $GADS_IMAGE \
       /gads/config-manager
