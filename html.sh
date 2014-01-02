#!/bin/bash

DIR=`dirname $0`
DATA="$HOME/.words"
FILE="$DATA/posts/.notitle.info"
LIST="$DATA/lists/.`date +"%Y-%m-%d"`.list"

# $1: file, $2: attr
function GET
{
        if [ ! -e $1 ]; then
                echo ""
        else
		LINE=""
                FIELD=$2
                LINE=`grep -i $FIELD $FILE`
		if [ -z LINE ]; then
			echo ""
		fi
                VALUE=`echo $LINE | awk -F '=' '{print $2}'`
                echo $VALUE
        fi
}

if [ ! -z $1 ]; then 
	# article ID is provided in $1
	if [[ ! "$1" == *[!0-9]* ]]; then
		ID=$1
		FILE="$DATA/posts/.$ID.info"
	elif [ x"$1" == x"marked" ] || [ x"$1" == x"m" ]; then
		if [ ! -e $LIST ]; then
			exit 1
		fi
		OLDIFS=$IFS
                IFS=$'\n'
		LINES="`cat $LIST`"	
		echo '<meta http-equiv="content-type" content="text/html;charset=gbk"/>'
		echo '<table><tbody>'
		for line in $LINES; do
			ID=`echo $line | awk -F '=' '{print $1}'`
			DIC="`echo $line | awk -F '=' '{print $2}'`"
			IFS=$OLDIFS
			for pos in $DIC; do
				echo '<tr><td>'
				$DIR/show.sh $ID $pos en	
				echo '</td><td>'
				$DIR/show.sh $ID $pos cn
				echo '</td></tr>'
			done
			IFS=$'\n'
		done
		echo '</tbody></table>'
		IFS=$OLDIFS
		exit 0
	elif [ x"$1" == x"number" ] || [ x"$1" == x"n" ]; then
		if [ ! -e $LIST ]; then
                        exit 1
                fi
                OLDIFS=$IFS
                IFS=$'\n'
                LINES="`cat $LIST`"
		echo '<meta http-equiv="content-type" content="text/html;charset=gbk"/>'
		NUM=0
                for line in $LINES; do
                        ID=`echo $line | awk -F '=' '{print $1}'`
                        DIC="`echo $line | awk -F '=' '{print $2}'`"
			if [ ! -z "$DIC" ]; then
				NEW=`echo "$DIC" | awk -F ' ' '{print NF}'`
			else
				NEW=0
			fi
			LEN=`$DIR/en/list.sh $ID -10`
			NUM=`expr $NUM + $LEN - $NEW`
                done
		COUNT=`expr 10000 - $NUM`
		echo "$COUNT words away from yearly target"
                IFS=$OLDIFS
                exit 0
	fi
fi
