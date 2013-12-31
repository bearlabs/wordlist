#!/bin/bash

export ID="$1"
PWD=`dirname $0`
PARENT_DIR=`dirname $PWD`
$PARENT_DIR/show.sh $1 first ec
