FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive \
    GCDS_MAJOR=4 \
    GCDS_MINOR=7 \
    GCDS_PATCH=2

ENV GCDS_VERSION=${GCDS_MAJOR}.${GCDS_MINOR}.${GCDS_PATCH}

COPY gcds.varfile /tmp/gcds.varfile

RUN apt-get update && \
    apt-get upgrade -yq && \
    apt-get -yq install libxext6 libxi6 libxrender1 libxtst6 python \
    python-ldap wget && \
    cd /tmp && \
    wget -O /tmp/dirsync-linux64.sh https://dl.google.com/dirsync/Google/GoogleCloudDirSync_linux_64bit_${GCDS_MAJOR}_${GCDS_MINOR}_${GCDS_PATCH}.sh && \
    /bin/sh dirsync-linux64.sh -q -varfile /tmp/gcds.varfile && \
    apt-get autoremove -y && \
    apt-get -yq clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

WORKDIR /gcds
