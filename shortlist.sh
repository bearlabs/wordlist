#!/bin/bash

DIR=`dirname $0`
source "$DIR/db/common.sh"

MAKEDIR

if [ ! -z $1 ]; then 
	# article ID is provided in $1
	if [[ ! "$1" == *[!0-9]* ]]; then
		ID=$1
		FILE="$DATA/posts/$ID.info"
	# no article ID; but command: clean
	elif [ x"$1" == x"reset" ] || [ x"$1" == x"r" ]; then
		rm -rf $DATA
		echo ""
		echo "All Marks Reset"
		echo ""
		exit 0
	elif [ x"$1" == x"marked" ] || [ x"$1" == x"m" ]; then
		if [ ! -e $LIST ]; then
			echo $LIST
			exit 1
		fi
		OLDIFS=$IFS
                IFS=$'\n'
		LINES="`cat $LIST`"	
		if [ -z "$2" ]; then
			for line in $LINES; do
				ID=`echo $line | awk -F '=' '{print $1}'`
				DIC="`echo $line | awk -F '=' '{print $2}'`"
				IFS=$OLDIFS
				for pos in $DIC; do
					$SHOW $ID $pos ec	
				done
				IFS=$'\n'
			done
			IFS=$OLDIFS
			exit 0
		elif [ "$2" == "next" ] || [ "$2" == "n" ]; then
			LEN=0
			CUR=0
			LLIST=$LIST.info
			POS=$(GET $LLIST POS)
			if [ -z "$POS" ]; then
				POS=1
			fi
                	for line in $LINES; do
				IFS=$OLDIFS
				ID=`echo $line | awk -F '=' '{print $1}'`
                        	DIC="`echo $line | awk -F '=' '{print $2}'`"
                        	if [ ! -z "$DIC" ]; then
                                	NUM=`echo "$DIC" | awk -F ' ' '{print NF}'`
					BUND=`expr $CUR + $NUM`
					if [ $POS -lt $BUND ] || [ $POS -eq $BUND ]; then
						for pos in $DIC; do
							CUR=`expr $CUR + 1`
							if [ "$CUR" == "$POS" ]; then
								LID=$ID
								LPOS=$pos
								NEXTPOS=`expr $POS + 1`
								SET $LLIST POS $NEXTPOS
							fi
						done		
					else
						CUR=`expr $CUR + $NUM`
					fi
                        	else
                                	NUM=0
                        	fi
                        	LEN=`expr $LEN + $NUM`
				IFS=$'\n'
                	done
			clear
			echo "#($POS/$LEN)"
			echo ""
			if [ $POS -lt $LEN ]; then
				POS=`expr $POS + 1`
			fi
			SET $LLIST LEN $LEN
                        $SHOW $LID $LPOS ec
			echo ""
			IFS=$OLDIFS
			exit 0
		fi
	elif [ x"$1" == x"passed" ] || [ x"$1" == x"p" ]; then
		if [ ! -e $LIST ]; then
                        exit 1
                fi
                OLDIFS=$IFS
                IFS=$'\n'
                LINES="`cat $LIST`"
                for line in $LINES; do
                        ID=`echo $line | awk -F '=' '{print $1}'`
                        DIC="`echo $line | awk -F '=' '{print $2}'`"
			if [ -z $DIC ]; then
				$SHOW $ID
				continue
			fi
			LEN=`$DIR/en/list.sh $ID -10`
			pos=0
			while [ $pos -lt $LEN ]; do
				pos=`expr $pos + 1`
				if [[ ! $DIC =~ (^| )$pos($| ) ]]; then
					$SHOW $ID $pos ec	
				fi
			done
                done
                IFS=$OLDIFS
                exit 0
	fi
fi
