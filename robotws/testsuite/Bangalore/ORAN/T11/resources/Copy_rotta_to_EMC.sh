#!/bin/bash
# Usage Copy_rotta_to_EMC.sh <Build> --> Will create a folder with specfied build in EMC path and copy logs to that folder
# Usage Copy_rotta_to_EMC.sh --> Will create a folder with name SBTS in EMC path and copy logs to that folder

####################################

if [[ "$#" -eq 0 ]];then
    Build=SBTS
elif [[ "$#" -eq 1 ]];then
    Build=$1
fi

sshpass -p "UPLl@bus3rl0g1n"  ssh -l inbaupllabuser 10.43.6.40 "mkdir MN_RAN_PZ_BLR_SG06; mkdir EMC_Logs;sudo /sbin/mount.cifs //eseefsn50.emea.nsn-net.net/rotta4internal/HetRAN_2/MN_RAN_PZ_BLR_SG06 /home/inbaupllabuser/MN_RAN_PZ_BLR_SG06/ -o username=wbts,password=Innovations@123; sudo mount 10.43.207.2:/ORAN/crt /home/inbaupllabuser/EMC_Logs; sudo cp -r /home/inbaupllabuser/MN_RAN_PZ_BLR_SG06/CB008957_ET/Execution_logs/ /home/inbaupllabuser/EMC_Logs/Trunk/Regression/RAN_PZ_BLR/RAN_PZ_BLR_6_SG/SG06_ORAN/ORAN/$Build/; echo done"
python /home/ute/robotws/testsuite/Bangalore/ORAN/SG06/resources/moving_logs_EMC.py /home/ute/testline_configuration_5G/Bangalore/UTE_Cloud_APOABIO/ ORAN/F1 /home/ute/EMC_Logs/Trunk/Regression/RAN_PZ_BLR/RAN_PZ_BLR_6_SG/SG06_ORAN/ORAN/$Build/ /home/ute/EMC_Logs/Trunk/Regression/RAN_PZ_BLR/RAN_PZ_BLR_6_SG/SG06_ORAN/
echo Copied logs to local EMC path
sudo rm -rf /home/ute/EMC_Logs/Trunk/Regression/RAN_PZ_BLR/RAN_PZ_BLR_6_SG/SG06_ORAN/ORAN/$Build/
sshpass -p "UPLl@bus3rl0g1n"  ssh -l inbaupllabuser 10.43.6.40 "sudo rm -rf /home/inbaupllabuser/MN_RAN_PZ_BLR_SG06/CB008957_ET/Execution_logs/*"
