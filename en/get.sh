#!/bin/bash

FULLSTR=$1
LEFTSTR="title=\""
RIGTSTR="\"\]"

TEMPSTR=$(echo ${FULLSTR%%$RIGTSTR*})
TEMPSTR=$(echo ${TEMPSTR##*$LEFTSTR})
echo $TEMPSTR | tr -d '?'
