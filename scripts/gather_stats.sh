#!/bin.sh

FILENAME=$1
COL=$2

CATLIST=`cat $FILENAME | grep -v TOTAL_GC_TIME | grep '\[' | awk -F, '{ print $1}' | sort -u | sed '1,$s/\[//g' | sed '1,$s/\]//g'`
#+CATLIST=`cat $FILENAME | grep '\[' | awk -F, '{ print $1}' | sort -u `



for i in $CATLIST 
do

#grep $i $FILENAME 
SUBCATLIST=`grep $i $FILENAME | awk -F, '{print $2 }'`

for sc in $SUBCATLIST
do

#grep $i $FILENAME 
	HDRVAL=`grep $i $FILENAME | grep $sc | awk -F, '{print $2 }'`
	SCVAL=`grep $i $FILENAME | grep $sc | awk -F, '{print $3 }'`

	if
		[ "$COL" = "HDR" ]
	then
		echo -n ${i}_$HDRVAL
	else
		echo -n $SCVAL

	fi

	echo -n ":"

done

#echo CAT=${i}_$CAT
#VAL=`grep $i $FILENAME | awk -F, '{print $3 }'`
#echo -n $i:$CAT:$VAL:
done


echo ":"
