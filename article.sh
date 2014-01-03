#!/bin/bash

DIR=`dirname $0`
source "$DIR/db/common.sh"

MAKEDIR

if [ ! -z $1 ]; then
        # article ID is provided in $1
        if [[ ! "$1" == *[!0-9]* ]]; then
                ID=$1
                FILE="$DATA/posts/$ID.info"
	fi
fi

if [ -z $1 ]; then
	$DIR/en/list.sh -l
elif [ -z $2 ]; then
	EN=`$DIR/en/list.sh $1`
	CN=`$DIR/cn/list.sh $1`
	NUM=`echo "$EN"|wc -l`
	POS=0
	while [ $POS -lt $NUM ]; do
		POS=`expr $POS + 1`
		DIC=$(GET $FILE DIC)
		if [ ! -z "$DIC" ]; then
			if [[ $DIC =~ (^| )$POS($| ) ]]; then
				$0 $1 $2 $POS ec
			fi
		else
			$0 $1 $2 $POS ec
		fi
	done
else
	LEN=$(GET $FILE LEN)
	DIC=$(GET $FILE DIC)
	if [ "$LEN" == "" ]; then
		LEN=`$DIR/en/list.sh $1 -10` # -10 indicates to get size
		SET $FILE LEN $LEN
	fi
	if [[ "$2" == *[!0-9]* ]]; then
		POS=$(GET $FILE POS)
		if [ -z $POS ]; then
			POS=0
			SET $FILE POS $POS
		fi	
		if [ "$2" == "reset" ] || [ "$2" == "r" ]; then
			if [ "$3" == "mark" ] || [ "$3" == "m" ] || [ "$3" == "unmark" ] || [ "$3" == "u" ]; then
                                exit 1
                        fi
			rm -rf $FILE
			echo ""
			echo "Marks Reset"
			echo ""
			exit 0
		elif [ "$2" == "save" ] || [ "$2" == "s" ]; then
			if [ "$3" == "mark" ] || [ "$3" == "m" ] || [ "$3" == "unmark" ] || [ "$3" == "u" ]; then
                                exit 1
                        fi
			DIC=$(GET $FILE DIC)
			SET $LIST $ID "$DIC"					
			echo ""
			echo "Marks Saved"
			echo ""
			exit 0
		elif [ "$2" == "mark" ] || [ "$2" == "m" ]; then
			if [ "$3" == "mark" ] || [ "$3" == "m" ] || [ "$3" == "unmark" ] || [ "$3" == "u" ]; then
                                exit 1
                        fi
			if [[ ! $DIC =~ (^| )$POS($| ) ]]; then
				if [ -z "$DIC" ]; then
					DIC="$POS"
				else
					DIC="$DIC $POS"
				fi
				SET $FILE DIC "$DIC"
			fi
			echo ""
			echo "Word Marked" 
			echo ""
			exit 0
		elif [ "$2" == "head" ] || [ "$2" == "h" ]; then
			if [ "$3" == "mark" ] || [ "$3" == "m" ] || [ "$3" == "unmark" ] || [ "$3" == "u" ]; then
                                exit 1
                        fi
			clear
			echo ""
			POS=1
		elif [ "$2" == "tail" ] || [ "$2" == "t" ]; then
			if [ "$3" == "mark" ] || [ "$3" == "m" ] || [ "$3" == "unmark" ] || [ "$3" == "u" ]; then
                                exit 1
                        fi
			clear
			echo ""
			POS=$LEN
		elif [ "$2" == "prev" ] || [ "$2" == "p" ]; then
			if [ "$3" == "mark" ] || [ "$3" == "m" ] || [ "$3" == "unmark" ] || [ "$3" == "u" ]; then
				exit 1
			fi
			clear
			echo ""
			if [ $POS -gt 1 ]; then
				POS=`expr $POS - 1`
			fi
		elif [ "$2" == "next" ] || [ "$2" == "n" ]; then
			if [ "$3" == "mark" ] || [ "$3" == "m" ] || [ "$3" == "unmark" ] || [ "$3" == "u" ]; then
                                exit 1
                        fi
			clear
			echo ""
			if [ $POS -ne $LEN ]; then
			POS=`expr $POS + 1`
			fi
		else
			clear
			echo ""
		fi
		SET $FILE POS $POS
		echo "#($POS/$LEN)"
		echo ""
		EN=`$DIR/en/list.sh $1 $POS`
		CN=`$DIR/cn/list.sh $1 $POS`
	else
		EN=`$DIR/en/list.sh $1 $2`
		CN=`$DIR/cn/list.sh $1 $2`
		POS=$2
		SET $FILE POS $POS 
	fi
	if [ -z "$3" ] || [ "$3" == "en" ] || [ "$3" == "n" ]; then
		echo $EN
	elif [ "$3" == "cn" ] || [ "$3" == "c" ]; then
		echo $CN
	elif [ "$3" == "ec" ]; then
		printf "%16s\t\t\t%s\n" "$EN" "$CN"
	elif [ "$3" == "ce" ]; then
		printf "%16s\t\t\t%s\n" "$CN" "$EN"
	fi
	if [ -z "$2" ] || [[ "$2" == *[!0-9]* ]]; then
		echo ""
	else
                if [ "$3" == "mark" ] || [ "$3" == "m" ]; then
                        if [[ ! $DIC =~ (^| )$POS($| ) ]]; then
                                if [ -z "$DIC" ]; then
                                        DIC="$POS"
                                else
                                        DIC="$DIC $POS"
                                fi
                                SET $FILE DIC "$DIC"
				echo ""
                                echo "Word Marked"
                        fi
                elif [ "$3" == "unmark" ] || [ "$3" == "u" ]; then
                        if [[ $DIC =~ (^| )$POS($| ) ]]; then
                                NEWDIC=""
                                for pos in $DIC; do
                                        if [ "$pos" != "$POS" ]; then
                                                if [ -z "$NEWDIC" ]; then
                                                        NEWDIC="$pos"
                                                else
                                                        NEWDIC="$NEWDIC $pos"
                                                fi
                                        fi
                                done
                                DIC="$NEWDIC"
                                SET $FILE DIC "$DIC"
				echo ""
                                echo "Word Unmarked"
                        else
                                exit 0
                        fi
                fi
	fi
fi
