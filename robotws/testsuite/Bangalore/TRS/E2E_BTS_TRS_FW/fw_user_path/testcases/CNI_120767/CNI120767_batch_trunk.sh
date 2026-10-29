!/bin/bash

#just replace 24R2 with latest Trunk Build after branch off
#date=`date`
#execution_date="${date// /_}"
#build=`grep "Active SW version" trace.txt | tail -1 | cut -b 23- | tr -d '"' | tr -d ',' | sed -e 's/24R2/00/g' `;



#export http_proxy="http://10.158.100.6:8080"
#export https_proxy="http://10.158.100.6:8080"
#export ftp_proxy="http://10.158.100.6:8080"


robot -L trace -b trace.txt -v  bts_id:1 CNI_120767_Alarm_with_automatic_link_speed_down_shift_for_Electrical_Ethernet_interfaces.robot


sleep 20

#/opt/ute/python3/bin/ute_reporting_portal send -p UTE -l label -l Local -ro output.xml -ca TRSSIV -tl TRSIV-TL0001 --sw_version $build -qc update.qc -v


sleep  50

robot -L trace -b trace.txt -v  bts_id:1 CNI_120767_Enable_Auto_Negotiation_on_EIF4_Interface.robot

sleep 20

#/opt/ute/python3/bin/ute_reporting_portal send -p UTE -l label -l Local -ro output.xml -ca TRSSIV -tl TRSIV-TL0001 --sw_version $build -qc update.qc -v

sleep  50

robot -L trace -b trace.txt -v  bts_id:1 CNI_120767_Check_Alarms_are_reported_for_ethernet_Physical_Link_layer_Lost.robot

sleep 20



#cd /home/ute/fw_user_path/testcases/Alarms_EDA_Aditya/

#sh batch_adi.sh
