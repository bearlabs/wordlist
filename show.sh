#!/bin/bash

DIR=`dirname $0`
DATA="$DIR/.data"
LIST="$DATA/.`date +"%Y-%m-%d"`.list"

if [ ! -d $DATA ]; then
	mkdir $DATA
fi

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
		echo "$2=$3" > $1
		for line in $LINES; do
			FIELD=`echo $line | awk -F '=' '{print $1}'`
			VALUE=`echo $line | awk -F '=' '{print $2}'`
			if [ "$2" != "$FIELD" ]; then
				echo $FIELD="$VALUE" >> $1
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

if [ ! -z $1 ]; then 
	# article ID is provided in $1
	if [[ ! "$1" == *[!0-9]* ]]; then
		ID=$1
		FILE="$DATA/.$ID.info"
	# no article ID; but command: clean
	elif [ x"$1" == x"clean" ]; then
		rm -rf $DATA
		echo ""
		echo "All Marks Removed"
		echo ""
		exit 0
	elif [ x"$1" == x"list" ]; then
		if [ ! -e $LIST ]; then
			exit 1
		fi
		OLDIFS=$IFS
                IFS=$'\n'
		LINES="`cat $LIST`"	
		#	echo ""
		for line in $LINES; do
			ID=`echo $line | awk -F '=' '{print $1}'`
			DIC="`echo $line | awk -F '=' '{print $2}'`"
			IFS=$OLDIFS
			for pos in $DIC; do
				$DIR/$0 $ID $pos ec	
			done
			IFS=$'\n'
		#	echo ""
		done
		IFS=$OLDIFS
		exit 0
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
	if [ -z "$2" ] || [[ "$2" == *[!0-9]* ]]; then
		POS=$(GET $FILE POS)
		if [ -z $POS ]; then
			POS=0
			SET $FILE POS $POS
		fi	
		if [ "$2" == "clean" ] || [ "$2" == "c" ]; then
			rm -rf $FILE
			echo ""
			echo "Marks Removed"
			echo ""
			exit 0
		elif [ "$2" == "save" ] || [ "$2" == "s" ]; then
			DIC=$(GET $FILE DIC)
			SET $LIST $ID "$DIC"					
			echo ""
			echo "Marks Saved"
			echo ""
			exit 0
		elif [ "$2" == "mark" ] || [ "$2" == "m" ]; then
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
		SET $FILE POS $POS
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
