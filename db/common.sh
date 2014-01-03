#!/bin/bash

DIR=`dirname $0`
DATA="$HOME/.words"
FILE="$DATA/posts/title.info"
LIST="$DATA/lists/`date +"%Y-%m-%d"`.list"
SHOW="$DIR/article.sh"

HOST="DBHOST"
USER="DBUSER"
PASS="DBPASS"
DB="DATABASE"

function MAKEDIR
{
	if [ ! -d $DATA ]; then
       		mkdir $DATA
	fi
	if [ ! -d $DATA/posts ]; then
        	mkdir $DATA/posts
	fi
	if [ ! -d $DATA/lists ]; then
        	mkdir $DATA/lists
	fi
}

# $1: file, $2: attr
function GET
{
        if [ ! -e $1 ]; then
                echo ""
        else
                LINE=""
                FIELD=$2
                LINE=`grep -i $FIELD $1`
                if [ -z LINE ]; then
                        echo ""
                fi
                VALUE=`echo $LINE | awk -F '=' '{print $2}'`
                echo $VALUE
        fi
}

#TODO: detect non-existence article id
# $1: file, $2: attr, $3: value
function SET
{
        # SET for the .list
        if [ x"$2" != x"POS" ] && [ x"$2" != x"LEN" ] && [ x"$2" != x"DIC" ]; then
                OLDIFS=$IFS
                IFS=$'\n'
                if [ -e $1 ]; then
                        LINES="`cat $1`"
                fi
		rm $1
		touch $1
                for line in $LINES; do
                        FIELD=`echo $line | awk -F '=' '{print $1}'`
                        VALUE=`echo $line | awk -F '=' '{print $2}'`
                        if [ "$2" != "$FIELD" ]; then
                                echo $FIELD="$VALUE" >> $1
			else
                		echo "$2=$3" >> $1
                        fi
                done
                IFS=$OLDIFS
                return
        fi

        # SET for the .info
        echo "$2=$3" > $1
        if [ ! -z $POS ] && [ x"$2" != x"POS" ]; then
                echo "POS=$POS" >> $1
        fi
        if [ ! -z $LEN ] && [ x"$2" != x"LEN" ]; then
                echo "LEN=$LEN" >> $1
        fi
        if [ ! -z "$DIC" ] && [ x"$2" != x"DIC" ]; then
                echo "DIC=$DIC" >> $1
        fi
}
