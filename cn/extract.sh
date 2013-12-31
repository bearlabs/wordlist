#!/bin/bash

DIR=$(dirname $0)
IFS=$'\n'
LINES=$(echo "$1" | sed 's/\[\/dt_tooltip\]/\[\/dt_tooltip\]^/g' | tr "^" "\n" | grep dt_tooltip | grep title=)
NUM=0
for line in $LINES
do
        NUM=$(expr $NUM + 1)
        if [ -z $2 ]; then
                $DIR/get.sh "${line}]"
        elif [ $2 -eq $NUM ]; then
                $DIR/get.sh "${line}]"
        fi
done
