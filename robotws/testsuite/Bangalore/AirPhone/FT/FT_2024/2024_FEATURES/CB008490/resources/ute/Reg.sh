#!/bin/bash
line_number=0
for i in $(cat $1)
do
reg_addr=$(echo $i | sed 's/\r$//')
#echo $reg_addr
if [[ "$reg_addr" =~ ^[0][x][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F][0-9a-fA-F] ]];then 	
	arvo=$(fpga_rw ra $reg_addr)
	echo "register $reg_addr value: $arvo" >> $2.log
else
	echo "line $line_number ignored : bad input format !!!"
fi
line_number=$((line_number+1))
done
