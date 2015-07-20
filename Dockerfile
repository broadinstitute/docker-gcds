FROM ubuntu:14.04

MAINTAINER Andrew Teixeira <teixeira@broadinstitute.org>

ENV DEBIAN_FRONTEND=noninteractive

ADD gads.varfile /tmp/gads.varfile

RUN apt-get update && \
    apt-get -yq install \
    libxext6 \
    libxi6 \
    libxrender1 \
    libxtst6 \
    wget && \
    wget -O /tmp/dirsync-linux64.sh http://dl.google.com/dirsync/dirsync-linux64.sh && \
    cd /tmp && \
    /bin/sh dirsync-linux64.sh -q -varfile /tmp/gads.varfile && \
    apt-get -yq clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

WORKDIR /gads
