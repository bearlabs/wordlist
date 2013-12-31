#!/bin/bash

DIR=`dirname $0`
FILE="$DIR/.info"

function GET
{
        if [ ! -e $FILE ]; then
                echo ""
        else
		LINE=""
                FIELD=$1
                LINE=`grep -i $FIELD $FILE`
		if [ -z LINE ]; then
			echo ""
		fi
                VALUE=`echo $LINE | awk -F '=' '{print $2}'`
                echo $VALUE
        fi
}

function SET
{
	echo "$1=$2" > $FILE	
        if [ ! -z $POS ] && [ x"$1" != x"POS" ]; then
                echo "POS=$POS" >> $FILE
	fi
        if [ ! -z $LEN ] && [ x"$1" != x"LEN" ]; then
                echo "LEN=$LEN" >> $FILE
	fi
        if [ ! -z "$DIC" ] && [ x"$1" != x"DIC" ]; then
                echo "DIC=$DIC" >> $FILE
        fi
}

if [ -z $1 ]; then
	rm -rf $FILE
	$DIR/en/list.sh -l
elif [ -z $2 ]; then
	EN=`$DIR/en/list.sh $1`
	CN=`$DIR/cn/list.sh $1`
	NUM=`echo "$EN"|wc -l`
	POS=0
	while [ $POS -lt $NUM ]; do
		POS=`expr $POS + 1`
		DIC=$(GET DIC)
		if [ ! -z "$DIC" ]; then
			if [[ $DIC =~ (^| )$POS($| ) ]]; then
				$0 $1 $2 $POS ec
			fi
		else
			$0 $1 $2 $POS ec
		fi
	done
else
	LEN=$(GET LEN)
	DIC=$(GET DIC)
	if [ "$LEN" == "" ]; then
		LEN=`$DIR/en/list.sh $1 -10` # -10 indicates to get size
		SET LEN $LEN
	fi
	if [ -z "$2" ] || [[ "$2" == *[!0-9]* ]]; then
		POS=$(GET POS)
		if [ -z $POS ]; then
			POS=0
			SET POS $POS
		fi	
		if [ "$2" == "exit" ] || [ "$2" == "e" ]; then
			rm -rf $FILE
			echo ""
			echo "Position Mark Removed"
			echo ""
			exit 0
		elif [ "$2" == "mark" ] || [ "$2" == "m" ]; then
			if [[ ! $DIC =~ (^| )$POS($| ) ]]; then
				if [ -z "$DIC" ]; then
					DIC="$POS"
				else
					DIC="$DIC $POS"
				fi
				SET DIC "$DIC"
			fi
			echo ""
			echo "Word has been marked successfully"
			echo ""
			exit 0
		elif [ "$2" == "head" ] || [ "$2" == "h" ]; then
			clear
			echo ""
			POS=1
		elif [ "$2" == "tail" ] || [ "$2" == "t" ]; then
			clear
			echo ""
			POS=$LEN
		elif [ "$2" == "prev" ] || [ "$2" == "p" ]; then
			clear
			echo ""
			if [ $POS -gt 1 ]; then
				POS=`expr $POS - 1`
			fi
		elif [ "$2" == "next" ] || [ "$2" == "n" ]; then
			clear
			echo ""
			if [ $POS -ne $LEN ]; then
			POS=`expr $POS + 1`
			fi
		else
			clear
			echo ""
		fi
		SET POS $POS
		echo "#($POS/$LEN)"
		echo ""
		EN=`$DIR/en/list.sh $1 $POS`
		CN=`$DIR/cn/list.sh $1 $POS`
	else
		EN=`$DIR/en/list.sh $1 $2`
		CN=`$DIR/cn/list.sh $1 $2`
	fi
	if [ -z "$3" ] || [ "$3" == "en" ] || [ "$3" == "n" ]; then
		echo $EN
	elif [ "$3" == "cn" ] || [ "$3" == "c" ]; then
		echo $CN
	elif [ "$3" == "ec" ]; then
		printf "%16s\t\t\t%s\n" "$EN" $CN
	elif [ "$3" == "ce" ]; then
		printf "%16s\t\t\t%s\n" $CN "$EN"
	fi
	if [ -z "$2" ] || [[ "$2" == *[!0-9]* ]]; then
		echo ""
	fi
fi
