#!/bin/bash
paste ./ips.txt ./cloud.txt ./bts.txt | while read fip fcloud fbts of; do
  trip=$(echo $fip | sed -e 's/[\r\n]//g')
  trcloud=$(echo $fcloud | sed -e 's/[\r\n]//g')
  trbts=$(echo $fbts | sed -e 's/[\r\n]//g')
  filename="./vnc/${trcloud}___${trip}___${trbts}.vnc"
  #filename="./vnc/${trcloud}___BTS-${trbts}.vnc"
  echo $fbts
  echo $trbts
  echo "ConnMethod=tcp" > $filename
  echo "Host=${trip}" >> $filename
  echo "Password=3dcce722dd0a689c63ff5932f82b078e" >> $filename
  echo "RelativePtr=0" >> $filename
done

