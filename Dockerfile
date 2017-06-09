FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive \
    GADS_MAJOR=4 \
    GADS_MINOR=4 \
    GADS_PATCH=26

ENV GADS_VERSION=${GADS_MAJOR}.${GADS_MINOR}.${GADS_PATCH}

COPY gads.varfile /tmp/gads.varfile

RUN apt-get update && \
    apt-get upgrade -yq && \
    apt-get -yq install libxext6 libxi6 libxrender1 libxtst6 python \
    python-ldap wget && \
    cd /tmp && \
    wget -O /tmp/dirsync-linux64.sh https://dl.google.com/dirsync/Google/GoogleCloudDirSync_linux_64bit_${GADS_MAJOR}_${GADS_MINOR}_${GADS_PATCH}.sh && \
    /bin/sh dirsync-linux64.sh -q -varfile /tmp/gads.varfile && \
    apt-get autoremove -y && \
    apt-get -yq clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

WORKDIR /gads
