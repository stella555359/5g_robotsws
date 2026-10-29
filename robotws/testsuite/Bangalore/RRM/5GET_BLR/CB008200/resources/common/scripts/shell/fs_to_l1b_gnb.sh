#!/bin/bash

rm -rf /ffs/run/swpool/OAM/tmp
cd /ffs/run/swpool/OAM
gNB_Position="$1"

if [[ $gNB_Position == left_side ]]; then
    new_tag='<tag name="app.btsom.nts.L1BypassMap"type="string">0x125D:0x524A<\/tag>'
else
    new_tag='<tag name="app.btsom.nts.L1BypassMap"type="string">0x225D:0x524A<\/tag>'
fi
echo $gNB_Position":"$new_tag

name=$(ls | grep "psconfig-A.*.txz$")
tar -xvf $name

status=$(sed -n "/${new_tag}/=" /ffs/run/swpool/OAM/tmp/rat_psconfig.xml)

if [[ -z $status ]]; then
    line_number=$(sed -n "/<\/config>/=" /ffs/run/swpool/OAM/tmp/rat_psconfig.xml)
    sed -i "${line_number}i\    ${new_tag}" /ffs/run/swpool/OAM/tmp/rat_psconfig.xml
    tar -czvf $name tmp/
    knife install $name /ffs/run/swpool/OAM/
fi
