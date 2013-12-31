#!/bin/bash

DIR=`dirname $0`
FILE="$DIR/.position"
LANG="en"

if [ -z $1 ]; then
	rm -rf $FILE
	$DIR/en/list.sh -l
elif [ -z $2 ]; then
	rm -rf $FILE
	EN=`$DIR/en/list.sh $1`
	CN=`$DIR/cn/list.sh $1`
	NUM=`echo "$EN"|wc -l`
	POS=0
	while [ $POS -lt $NUM ]; do
		POS=`expr $POS + 1`
		$0 $1 $2 $POS ec
	done
else
	if [ -z "$2" ] || [[ "$2" == *[!0-9]* ]]; then
		if [ ! -e $FILE ]; then
			POS=0
			echo $POS > $FILE
		fi	
		POS=`cat $FILE`
		if [ "$2" == "exit" ]; then
			clear
			rm -rf $FILE
			echo "Position Mark Removed"
			exit 0
		elif [ "$2" == "head" ]; then
			clear
			echo ""
			POS=1
		elif [ "$2" == "prev" ]; then
			clear
			echo ""
			POS=`expr $POS - 1`
		elif [ "$2" == "next" ]; then
			clear
			echo ""
			POS=`expr $POS + 1`
		else
			clear
			echo ""
		fi
		echo $POS > $FILE
		echo "#$POS"
		echo ""
		EN=`$DIR/en/list.sh $1 $POS`
		CN=`$DIR/cn/list.sh $1 $POS`
	else
		EN=`$DIR/en/list.sh $1 $2`
		CN=`$DIR/cn/list.sh $1 $2`
	fi
	if [ -z "$3" ] || [ "$3" == "en" ]; then
		echo $EN
	elif [ "$3" == "cn" ]; then
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
