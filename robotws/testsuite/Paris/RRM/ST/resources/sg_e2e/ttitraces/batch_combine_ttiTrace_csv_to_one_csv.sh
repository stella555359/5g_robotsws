#!/bin/bash
set -ex

# USAGE:	
# combines ul trace files to one file (header lines from first file, only data from the rest)
# $1 : the last number file which should be combined

FILENAMEPREFIX=L2TtiTrace_EventsSnapshot.bin.
FILENAMESUFFIXDL=.dl.csv
FILENAMESUFFIXUL=.ul.csv
FILENAME=none
HEADERFOUND=0
OUTFILEDL=combined_dl_trace.csv
OUTFILEUL=combined_ul_trace.csv

#for i in {1..17}
for ((i=1; i<=$1; i++));
do
     FILENAME="$FILENAMEPREFIX""$i""$FILENAMESUFFIXUL"
     echo "$FILENAME"
     if [ -f $FILENAME ]; then
       if [ "$HEADERFOUND" -eq 0 ];then 
         cat "$FILENAME" >> "$OUTFILEUL"
         HEADERFOUND=1
       else
         tail -n +3 "$FILENAME" >> "$OUTFILEUL"
       fi
     else
        echo "file not found!"
     fi
done

HEADERFOUND=0

#for i in {1..$1}
for ((i=1; i<=$1; i++));
do
     FILENAME="$FILENAMEPREFIX""$i""$FILENAMESUFFIXDL"
     echo "$FILENAME"
     if [ -f $FILENAME ]; then
       if [ "$HEADERFOUND" -eq 0 ];then 
         cat "$FILENAME" >> "$OUTFILEDL"
         HEADERFOUND=1
       else
         tail -n +3 "$FILENAME" >> "$OUTFILEDL"
       fi
     else
        echo "file not found!"
     fi
done

