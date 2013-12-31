#!/bin/bash

FULLSTR=$1
LEFTSTR="\]"
RIGTSTR="\[\/dt_tooltip\]"

TEMPSTR=$(echo ${FULLSTR%%$RIGTSTR*})
TEMPSTR=$(echo ${TEMPSTR##*$LEFTSTR})
echo $TEMPSTR
