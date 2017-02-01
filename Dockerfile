FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive \
    GADS_VERSION=4.4.22

COPY gads.varfile /tmp/gads.varfile

RUN apt-get update && \
    apt-get upgrade -yq && \
    apt-get -yq install libxext6 libxi6 libxrender1 libxtst6 python \
    python-ldap wget && \
    cd /tmp && \
    wget https://dl.google.com/dirsync/dirsync-linux64.sh && \
    /bin/sh dirsync-linux64.sh -q -varfile /tmp/gads.varfile && \
    apt-get autoremove -y && \
    apt-get -yq clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

WORKDIR /gads
