#!/bin/bash
paste ./ips.txt ./cloud.txt ./bts.txt | while read fip fcloud fbts of; do
  trip=$(echo $fip | sed -e 's/[\r\n]//g')
  trcloud=$(echo $fcloud | sed -e 's/[\r\n]//g')
  trbts=$(echo $fbts | sed -e 's/[\r\n]//g')
  echo "[Sessions\_${trcloud}___${trip}___${trbts}]"
  echo "[Sessions\_${trcloud}___${trip}___${trbts}]" >> "./scp/WinSCP.ini"
  echo "HostName=${trip}" >> "./scp/WinSCP.ini"
  echo "UserName=ute" >> "./scp/WinSCP.ini"
  echo "Password=A35C4A4C40A5729C3845390E971B789F2360529D2928396D6C72686E726A6E72646B2928390908197D7DA8FD818EC8334F09" >> "./scp/WinSCP.ini"
  echo " "
done
