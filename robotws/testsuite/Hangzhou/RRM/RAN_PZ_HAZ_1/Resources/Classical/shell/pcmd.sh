#!/bin/bash
cd $1
echo "hello cell id ${2}"
rm *MME.gz
for x in *pcmd.gz; do echo $x; gzip -dc $x | grep 262:03 |grep F| grep -i $2; done > pcmdfile0
grep 262 pcmdfile0 > record_pcmd.txt
rm pcmdfile0
rm *.gz
cat record_pcmd.txt
time=$(date "+%F.%H:%M%z")
filename=$(echo $time.MMEpcmd)
mv record_pcmd.txt $filename
#echo $filename
gzfilename=$(echo $filename.gz)
#echo $gzfilename
gzip *pcmd
