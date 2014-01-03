#!/bin/bash

DIR=`dirname $0`
source "$DIR/db/common.sh"
LLIST=$LIST.info

MAKEDIR

if [ ! -z $1 ]; then 
	# command: clean
	if [ "$1" == "reset" ] || [ "$1" == "r" ]; then
		rm -rf $DATA
		echo ""
		echo "All Marks Reset"
		echo ""
	elif [ "$1" == "length" ] || [ "$1" == "l" ]; then
                if [ ! -e $LIST ]; then
                        echo $LIST
                        exit 1
                fi
		LEN=0
                LINES="`cat $LIST`"
                OLDIFS=$IFS
                IFS=$'\n'
                for line in $LINES; do
                	DIC="`echo $line | awk -F '=' '{print $2}'`"
			NUM=`echo $DIC | awk -F ' ' '{print NF}'`
			LEN=`expr $LEN + $NUM`
                done
                IFS=$OLDIFS
		echo $LEN
	elif [ "$1" == "old" ] || [ "$1" == "o" ]; then
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
	else
		if [ ! -e $LIST ]; then
			exit 1
		fi
		OLDIFS=$IFS
                IFS=$'\n'
		LINES="`cat $LIST`"	
		if [[ ! "$1" == *[!0-9]* ]]; then
                        POS=$1
                        LEN=0
                        CUR=0
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
                                                                SET $LLIST POS $POS
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
                        SET $LLIST LEN $LEN
			if [ -z $2 ]; then
                        	$SHOW $LID $LPOS
			else
				$SHOW $LID $LPOS $2
				if [ "$2" == "unmark" ] || [ "$2" == "u" ]; then
					$SHOW $LID save
					POS=`expr $POS - 1`
					SET $LLIST POS $POS
				fi
			fi
                        IFS=$OLDIFS
		elif [ "$1" == "head" ] || [ "$1" == "h" ]; then
			LEN=`$DIR/$0 length`
			POS=1
			if [ "$2" == "mark" ] || [ "$2" == "m" ] || [ "$2" == "unmark" ] || [ "$2" == "u" ]; then
                                exit 1
                        fi
                        clear
                        echo "#($POS/$LEN)"
                        echo ""
                        $DIR/$0 $POS $2
                        echo ""
		elif [ "$1" == "tail" ] || [ "$1" == "t" ]; then
			LEN=`$DIR/$0 length`
                        POS=$LEN
                        if [ "$2" == "mark" ] || [ "$2" == "m" ] || [ "$2" == "unmark" ] || [ "$2" == "u" ]; then
                                exit 1
                        fi
                        clear
                        echo "#($POS/$LEN)"
                        echo ""
                        $DIR/$0 $POS $2
                        echo ""
		elif [ "$1" == "next" ] || [ "$1" == "n" ]; then
			LEN=`$DIR/$0 length`
			POS=$(GET $LLIST POS)
			if [ -z "$POS" ]; then
				POS=0
			fi
                        if [ $POS -lt $LEN ]; then
                                POS=`expr $POS + 1`
                        fi
			if [ "$2" == "mark" ] || [ "$2" == "m" ] || [ "$2" == "unmark" ] || [ "$2" == "u" ]; then
				exit 1
			fi
			clear
			echo "#($POS/$LEN)"
			echo ""
                       	$DIR/$0 $POS $2
			echo ""
                elif [ "$1" == "prev" ] || [ "$1" == "p" ]; then
                        LEN=`$DIR/$0 length`
                        POS=$(GET $LLIST POS)
                        if [ -z "$POS" ]; then
                                POS=1
                        fi
                        if [ $POS -gt 1 ]; then
                                POS=`expr $POS - 1`
                        fi
			if [ "$2" == "mark" ] || [ "$2" == "m" ] || [ "$2" == "unmark" ] || [ "$2" == "u" ]; then
				exit 1
			fi
                      	clear
                       	echo "#($POS/$LEN)"
                       	echo ""
                       	$DIR/$0 $POS $2
                       	echo ""
		elif [ "$1" == "unmark" ] || [ "$1" == "u" ]; then
			POS=$(GET $LLIST POS)
			if [ -z "$POS" ]; then
				POS=1
			fi
			$DIR/$0 $POS unmark
		fi
	fi
else
        OLDIFS=$IFS
        IFS=$'\n'
        LINES="`cat $LIST`"
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
fi
