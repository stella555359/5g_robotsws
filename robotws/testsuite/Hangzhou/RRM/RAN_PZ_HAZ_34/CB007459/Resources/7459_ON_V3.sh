#!/bin/bash
#
##################################################################################
# Script to enable and configure feature CB007459                                #
# USAGE                                                                          #
#   - Copy script files to ASIK/ASIB (/ffs/run)                                  #
#   - Give execution rights                                                      #
#       chmod +x /ffs/run/7459_ON.sh                                             #
#   - Modify Variables in 7459_ON.sh                                             #
#   - Run script ./7459_ON.sh                                                    #
#                                                                                #
# LINKS AND INFORMATION                                                          #
#   Script is stored in rotta:                                                   #
#     \\eseefsn50.emea.nsn-net.net\rotta4internal\5G_2\pgolabek\CB007459\Scripts #                                #
#                                                                                #
# HISTORY:                                                                       #
#   06.05.2021  V1:  - The first version.                                        #
#   02.07.2021  V2:  - Basic Error protection added.                             #
#		     - Service ASIB added      		                                     #
#   14.07.2021  V3:  - Fixed problem with CPUE exceptions and reset loop         #
#                    - Fixed typos and details after collaborator review         #
# BUG REPORTS:                                                                   #
#   Provide console log to piotr.golabek@nokia.com			                	 #
#                             							                         #
#			                SyVe Wroclaw PZ2WRO4                                 #
#                                                                                #
##################################################################################

#backup /ffs/run/HashContainer* files to /ffs/run/config/toor4nsn/HashContainer_bk
#if not recover HashContainer* files will result in rollback failure
mkdir -p /ffs/run/config/toor4nsn/HashContainer_bk
mkdir -p /ffs/run/config/toor4nsn/sm6-snowfish_bk
mkdir -p /ffs/run/config/toor4nsn/airscale5g-xeon_bk
cp /ffs/run/HashContainer* /ffs/run/config/toor4nsn/HashContainer_bk
cp /ffs/run/swpool/CPLANE-5G/sm6-snowfish/cp-ue_*.txz /ffs/run/config/toor4nsn/sm6-snowfish_bk
cp /ffs/run/swpool/CPLANE-5G/airscale5g-xeon/cp-ue_*.txz /ffs/run/config/toor4nsn/airscale5g-xeon_bk

set -e #In case of any error withaut pipelining - exit immediately
set -u #Exit if there is unbound (unused) variable
scriptName=`echo $0 | cut -c 3-`
HW_type=`head -c 4 /proc/device-tree/module-identity/unit-id`


######################## SKT PLMN & SPID ########################################
rdSktPlmnId=6484528;
rdSktSpId=12;
###################### UL PowerControl ##########################################
rdUlPowerControl=1;
rdP0NominalPucch=94;
rdP0NominalPucchF1F3=94;
rdP0NominalPusch=130;
rdP0NominalSrs=130;
rdAlpha=7;
rdInitialPreambleReceivedTargetPower=98;
rdPMaxNROwnCell=50;
###################  UL proactive scheduling  ###################################
rdActProactULScheduling=1;
###################  InactivityTimer ############################################
rdNsaInactivityTimer=12;
rdActInactDetNSAUe=False;
#################################################################################
#Values from "Enable RnD Parameters for CB007459" Author: Maria.Koszucka@nokia.com

booltoStr (){
    if [ "$1" -eq 0  ];
    then
        echo "False"
    else
        echo "True"
    fi
}

function ReplData {

sed -i "s/rdNsaInactivityTimer=[0-9]\{2\}/rdNsaInactivityTimer=$rdNsaInactivityTimer/" /tmp/tmp/opt/nokia/SS_CPLANE/etc/cp_ue.enb_conf.ini
sed -i "s/rdSktPlmnId=.*/rdSktPlmnId=$rdSktPlmnId/" /tmp/tmp/opt/nokia/SS_CPLANE/etc/cp_ue.enb_conf.ini
sed -i "s/rdSktSpId=[0-9]\{2\}/rdSktSpId=$rdSktSpId/" /tmp/tmp/opt/nokia/SS_CPLANE/etc/cp_ue.enb_conf.ini
sed -i "s/rdActInactDetNSAUe.*/rdActInactDetNSAUe=$rdActInactDetNSAUe/" /tmp/tmp/opt/nokia/SS_CPLANE/etc/cp_ue.enb_conf.ini
sed -i "s/rdActProactULScheduling.*/rdActProactULScheduling=$(booltoStr $rdActProactULScheduling)/" /tmp/tmp/opt/nokia/SS_CPLANE/etc/cp_ue.enb_conf.ini
sed -i "s/rdUlPowerControl=.*/rdUlPowerControl=$(booltoStr $rdUlPowerControl)/" /tmp/tmp/opt/nokia/SS_CPLANE/etc/cp_ue.enb_conf.ini
echo -e "cp_ue.enb_conf.ini edited"
}

echo "   _____   ____     ___     ___    ______   _  _     _____    ___  "
echo "  / ____| |  _ \   / _ \   / _ \  |___   | | || |   | ____|  / _ \ "
echo " | |      | |_) | | | | | | | | |     / /  | || |_  | |__   | (_) |"
echo " | |      |  _ <  | | | | | | | |    / /   |__   _| |___ \   \__, |"
echo " | |____  | |_) | | |_| | | |_| |   / /       | |    ___) |    / / "
echo "  \_____| |____/   \___/   \___/   /_/        |_|   |____/    /_/  "
echo "                                                                   "

echo -e "\n$scriptName - Script to enable and configure feature CB007459"
echo -e "\nHW type: $HW_type"

case "$rdAlpha" in
  "0") rdAlphaDU=al0 ;;
  "1") rdAlphaDU=al4 ;;
  "2") rdAlphaDU=al5 ;;
  "3") rdAlphaDU=al6 ;;
  "4") rdAlphaDU=al7 ;;
  "5") rdAlphaDU=al8 ;;
  "6") rdAlphaDU=al9 ;;
  "7") rdAlphaDU=al1 ;;
  *) echo "ERR: wrong rdAlphaDU value"
esac

echo -e "\nrdSktPlmnId=\t\t\t\t$rdSktPlmnId\t Real Value: MCC=XXX MNC=YY They can be calculated based on 3GPP TS 38.473 Section 9.3.1.14 "
echo -e "rdSktSpId=\t\t\t\t$rdSktSpId\t Real Value: DU=$rdSktSpId \tCU=$rdSktSpId "
echo -e "rdUlPowerControl=\t\t\t$rdUlPowerControl\t Real Value: DU=$rdUlPowerControl \tCU=$(booltoStr $rdUlPowerControl) "
echo -e "rdP0NominalPucch=\t\t\t$rdP0NominalPucch\t Real Value: DU=$(($rdP0NominalPucch-202)) "
echo -e "rdP0NominalPucchF1F3=\t\t\t$rdP0NominalPucchF1F3\t Real Value: DU=$(($rdP0NominalPucchF1F3-202)) "
echo -e "rdP0NominalPusch=\t\t\t$rdP0NominalPusch\t Real Value: DU=$(($rdP0NominalPusch-202)) "
echo -e "rdP0NominalSrs=\t\t\t\t$rdP0NominalSrs\t Real Value: DU=$(($rdP0NominalSrs-202))"
echo -e "rdAlpha=\t\t\t\t$rdAlpha\t Real Value: DU=$rdAlphaDU"
echo -e "rdInitialPreambleReceivedTargetPower=\t$rdInitialPreambleReceivedTargetPower\t Real Value: DU=$(($rdInitialPreambleReceivedTargetPower-202)) "
echo -e "rdPMaxNROwnCell=\t\t\t$rdPMaxNROwnCell\t Real Value: DU=$(($rdPMaxNROwnCell-30))"
echo -e "rdActProactULScheduling=\t\t$rdActProactULScheduling\t Real Value: DU=$rdActProactULScheduling \tCU=$(booltoStr $rdActProactULScheduling) "
echo -e "rdNsaInactivityTimer=\t\t\t$rdNsaInactivityTimer\t Real Value: DU= -- \tCU=$rdNsaInactivityTimer "
echo -e "rdActInactDetNSAUe=\t\t\t$rdActInactDetNSAUe\t Real Value: DU= -- \tCU=$rdActInactDetNSAUe "

#echo -e "\nAll aboves values are correct? ? <yes/no>"
#echo "Double check values !"
#read -r Correct_values
#
#if [[ $Correct_values = yes ]]
#	then
#		echo "Data loaded."
#	else
#       	echo "Script will be Stopped! Edit file and rerun."
#	exit
#fi

rm -rf /tmp/tmp
mkdir /tmp/tmp
echo -e "/tmp/tmp folder was created."
cp /ffs/run/swpool/CPLANE-5G/sm6-snowfish/cp-ue_*.txz /tmp/tmp
cd /tmp/tmp
cp_ue=`ls`
echo $cp_ue
echo -e "\nUnpacking files in progress."
tar xvf /tmp/tmp/cp-ue_*.txz --warning=no-timestamp
rm /tmp/tmp/cp-ue_*.txz
ReplData
echo -e "\nPacking files in progress.\n"
tar czvf /tmp/tmp/$cp_ue *
cp /tmp/tmp/cp-ue_*.txz /ffs/run/swpool/CPLANE-5G/sm6-snowfish
crasign /ffs/run/swpool/CPLANE-5G/sm6-snowfish/cp-ue_*.txz
echo -e "File signed."

if [[ $HW_type = ASIB ]];
	then
		echo -e "\nnext file /ffs/run/swpool/CPLANE-5G/airscale5g-xeon/cp-ue_*.txz"
		rm -rf /tmp/tmp
		mkdir /tmp/tmp
		echo -e "/tmp/tmp folder was created."
		cp /ffs/run/swpool/CPLANE-5G/airscale5g-xeon/cp-ue_*.txz /tmp/tmp
		cd /tmp/tmp
		cp_ue=`ls`
		echo $cp_ue
		echo -e "\nUnpacking files in progress."
		tar xvf /tmp/tmp/cp-ue_*.txz --warning=no-timestamp
		rm /tmp/tmp/cp-ue_*.txz
		ReplData
		echo -e "\nPacking files in progress.\n"
		tar czvf /tmp/tmp/$cp_ue *
		cp /tmp/tmp/cp-ue_*.txz /ffs/run/swpool/CPLANE-5G/airscale5g-xeon/
		crasign /ffs/run/swpool/CPLANE-5G/airscale5g-xeon/cp-ue_*.txz
		echo -e "File signed."
fi


##############################################################################################################

sed -i "/$scriptName/d" /ffs/run/swconfig.txt
sed -i "/0x5900/d" /ffs/run/swconfig.txt

echo -e "################################## edited by $scriptName  ########################################### " >> /ffs/run/swconfig.txt
echo -e "0x5900CA=$rdSktPlmnId" >> /ffs/run/swconfig.txt
echo -e "0x5900CB=$rdSktSpId" >> /ffs/run/swconfig.txt
echo -e "0x5900CC=$rdUlPowerControl" >> /ffs/run/swconfig.txt
echo -e "0x5900CD=$rdP0NominalPucch" >> /ffs/run/swconfig.txt
echo -e "0x5900CE=$rdP0NominalPucchF1F3" >> /ffs/run/swconfig.txt
echo -e "0x5900CF=$rdP0NominalPusch" >> /ffs/run/swconfig.txt
echo -e "0x5900D0=$rdP0NominalSrs" >> /ffs/run/swconfig.txt
echo -e "0x5900D1=$rdAlpha" >> /ffs/run/swconfig.txt
echo -e "0x5900D2=$rdInitialPreambleReceivedTargetPower" >> /ffs/run/swconfig.txt
echo -e "0x5900D3=$rdPMaxNROwnCell" >> /ffs/run/swconfig.txt
echo -e "0x5900DF=$rdActProactULScheduling" >> /ffs/run/swconfig.txt
echo -e "# Values from 'Enable RnD Parameters for CB007459' Author: Maria.Koszucka@nokia.com $scriptName " >> /ffs/run/swconfig.txt
echo -e "################################## edited by $scriptName  ########################################### " >> /ffs/run/swconfig.txt

#############################################################################################################

rm -f /ffs/run/HashContainer*
echo "Hash Containers were removed if existed :) !"

# echo -e "Press some key to reboot, after that configuration will be aplied"
# read -r
reboot
