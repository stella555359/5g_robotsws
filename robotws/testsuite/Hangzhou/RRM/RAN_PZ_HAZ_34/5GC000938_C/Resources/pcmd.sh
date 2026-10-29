#!/bin/sh

startnu=$(sed -n ${3}p ${1}/pcmd_line_nu.txt)

cat ${1}/Emil_log_PCMD.txt | tail -n +${startnu} | head -n +${2} > ${1}/pcmd

awk '{print $2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17}' ${1}/pcmd | sed '1d' | sed ':label;N;s/\n/ /;b label' | sed 's/://g' > ${1}/pcmd_tmp

#cat ${1}/pcmd | sed '1d' | sed -e 's/[^ ]* //' | sed ':label;N;s/\n/ /;b label' | sed 's/://g' > ${1}/pcmd

cat ${1}/pcmd_tmp > ${1}/pcmd

rm -rf ${1}/pcmd_tmp


