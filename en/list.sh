#!/bin/bash

DIR=`dirname $0`
DBDIR=`dirname $DIR`/db
source "$DBDIR/common.sh"

OPER="PROCESS"
NUM=-1
ID=$1
if [ ! -z $2 ]; then
	NUM=$2
fi
while getopts "li:n:" str; do
        case "${str}" in
	n)
		NUM=${OPTARG}
		;;
	l)
		OPER="LIST"
		;;
	i)
		OPER="PROCESS"
		ID=${OPTARG}
		;;	
	*)
		echo "" > /dev/null
		;;
	esac
done

if [ "$OPER" == "LIST" ]; then
	mysql -u$USER -h$HOST -p$PASS $DB -e "set names gbk;select wp_posts.ID,post_title as TITLE,user_nicename as AUTHOR,post_date as DATE from wp_posts,wp_users where post_status='publish' and post_type='post' and wp_posts.post_author=wp_users.ID order by post_date desc;"
elif [ "$OPER" == "PROCESS" ]; then
	TEXT=$(mysql -u$USER -h$HOST -p$PASS $DB -e "set names gbk;select post_content from wp_posts where ID=${ID};" | grep \[dt_tooltip\])
	if [ $NUM -eq -10 ]; then
		$DIR/status.sh "$TEXT"
	elif [ $NUM -eq -1 ]; then
		$DIR/extract.sh "$TEXT"
	else
		$DIR/extract.sh "$TEXT" $NUM
	fi
fi
