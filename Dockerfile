FROM ubuntu:14.04

ENV DEBIAN_FRONTEND=noninteractive \
    GADS_MAJOR=4 \
    GADS_MINOR=2 \
    GADS_PATCH=0

ENV GADS_VERSION=${GADS_MAJOR}.${GADS_MINOR}.${GADS_PATCH}

ADD gads.varfile /tmp/gads.varfile

RUN apt-get update && \
    apt-get -yq install \
    libxext6 \
    libxi6 \
    libxrender1 \
    libxtst6 \
    python \
    python-ldap \
    wget && \
    wget -O /tmp/dirsync-linux64.sh http://dl.google.com/dirsync/google/googleappsdirsync_linux_64bit_${GADS_MAJOR}_${GADS_MINOR}_${GADS_PATCH}.sh && \
    cd /tmp && \
    /bin/sh dirsync-linux64.sh -q -varfile /tmp/gads.varfile && \
    apt-get -yq clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

WORKDIR /gads
