#!/bin/bash

######################################################################################################################
# Script to stops tcpdump and collect traces (calling sosReport_ASIL.sh) triggered by startTest_ASIL.sh
# AP / ASIL+ABIO or ASOE and GNB / ASIK+ABIL or GNB / ASIB+ABIL or ASIB+ABIO/ABIN or ASIL+ABIO/ABIN
# vRAN is also supported in front of AP / ASIL+ABIO or ASOE but without gNB tcpdump
# Script called by ../stopTest.sh (from eg /opt/iphy/ latest/)
######################################################################################################################

WORK_DIR=$(dirname "$0")
CONF_FILE=$WORK_DIR/../sosReport.cfg

AP_CTRL=none
AP_BSH_1=none
AP_BSH_2=none
AP_BSH_3=none
GNB_CTRL=none
GNB_BSH_1=none
GNB_BSH_2=none
GNB_BSH_3=none

GNB_LOG=true

if [ -f "$CONF_FILE" ];then
  . "$CONF_FILE"
else
  print "no config file $CONF_FILE"
  exit
fi

if [ -f "$HOME/.ssh/toor4nsn/id_rsa" ] ; then
    PRIVATE_KEY="$HOME/.ssh/toor4nsn/id_rsa"
elif [ -f "$HOME/.ssh/id_rsa" ] ; then
    PRIVATE_KEY="$HOME/.ssh/id_rsa"
else
    echo "ERROR: Could not find ssh keys in $HOME/.ssh/ will generate new ones"
    ssh-keygen -t rsa -N "" -f "$HOME/.ssh/id_rsa"
    PRIVATE_KEY="$HOME/.ssh/id_rsa"
fi

ssh="ssh -q -o StrictHostkeyChecking=no -i $PRIVATE_KEY "

function update_ssh_config()
{
  chmod 600 "$PRIVATE_KEY"
  chmod 644 "$PRIVATE_KEY.pub"
  if [[ (! $(which sshpass)) ]]; then
    echo "-------ERROR-------"
    echo "sshpass not installed! Script not to be used!"
    echo "Type: \"apt install sshpass\" or \"yum install sshpass\" for installation"
    echo "-------------------"
    echo "will try to continue anyway after 3 seconds"
    sleep 3
  else
    var=BTS_IP_1
    if [ "1${!var}" != "1" ]; then
      BTS_IP=${!var}
      sshpass -p "${PASSWORD}" ssh-copy-id -i "$PRIVATE_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o CheckHostIP=no -o ConnectTimeout=5s "$TL_USER"@"$BTS_IP_1"
    else
      echo "$(tput setaf 3)Classical gNB IP address $var not filled in $CONF_FILE$(tput sgr 0)"
      echo "$(tput setaf 3)Script carries on assuming vRAN gNB or DUsim$(tput sgr 0)"
      BTS_IP="192.168.255.129"
      GNB_LOG="false"
    fi
    sshpass -p "${PASSWORD}" ssh-copy-id -i "$PRIVATE_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o CheckHostIP=no -o ConnectTimeout=5s "$TL_USER"@"$IPHY_FCT_IP_1"
  fi
}

function disablePortMirroring()
{
    $ssh "$TL_USER"@"$1" '(bsh 1:0 dbgnac mirror sport 12 dport 5 d)' > /dev/null 2>&1
    $ssh "$TL_USER"@"$1" '(bsh 1:0 dbgnac mirror sport 5 dport 20 d)' > /dev/null 2>&1
}

function find_conf()
{
  echo "------------ Find $2 HW configuration ------------"
  $($ssh -o ConnectTimeout=10 $TL_USER@$1 "chk sysbshtopo" > /tmp/test.txt)
  test=$(grep -w ctrll /tmp/test.txt | awk '{print $4}')
  if [ "$2" == "AP" ]; then
    if [ "$test" != "ASIL" ] && [ "$test" != "ASOE" ]; then
      echo ERROR: SCRIPT NOT APPLICABLE FOR "$2" on "$test"
      exit
    else
      echo "$2" Control Board is "$test"
      AP_CTRL=$test
    fi
  elif [ "$test" = "" ]; then
    echo "$(tput setaf 3)No info available for Classical $2 HW$(tput sgr 0)"
    echo "$(tput setaf 3)No Classical $2 logs will be collected$(tput sgr 0)"
    GNB_LOG="false"
    return
  else
    echo "$2" Control Board is "$test"
    GNB_CTRL=$test
  fi

  for bsh in 1:0 2:0 3:0
    do
      slot=$(grep -w $bsh /tmp/test.txt | awk '{print $3}')
      slot=${slot:1:1}
      if [ "$slot" == "" ]; then
        echo no "$2" board found for bsh "$bsh"
      else
        board=$(grep -w $bsh /tmp/test.txt | awk '{print $4}')
        echo "$2" Baseband Board "$board" found for bsh $bsh in slot "$slot"
        if [ "$2" == "AP" ]; then
          if [ "$bsh" == "1:0" ]; then
            AP_BSH_1=$board
          elif [ "$bsh" == "2:0" ]; then
            AP_BSH_2=$board
          else
            AP_BSH_3=$board
          fi
        else
          if [ "$bsh" == "1:0" ]; then
            GNB_BSH_1=$board
          elif [ "$bsh" == "2:0" ]; then
            GNB_BSH_2=$board
          else
            GNB_BSH_3=$board
          fi
        fi
      fi
    done
}

function kill_bip_pcap_process()
{
  echo "------------ Find BIP pcap process running on $1 ------------"
  $ssh "$TL_USER"@"$1" "ps -edf | grep tcpdump | grep _tcpdump_L2L1_bip_filtering_off | grep -v bash" > /tmp/process_bip_"$1".txt
  while IFS= read -r line; do
    test=$(echo "$line" | awk '{print $2}')
    echo kill -9 "$test"
    $ssh "$TL_USER"@"$1" kill -9 "$test" &
  done < /tmp/process_bip_"$1".txt
}

function kill_pcap_process()
{
  echo "------------ Find pcap processes running on $1 ------------"
  # for some reason one attempt may not be enough and all tcpdump tasks are not killed
  # any improvement or correction is welcome...
  $ssh "$TL_USER"@"$1" "ps -edf | grep tcpdump | grep sosReport | grep -v bash" > /tmp/process_list1_"$1".txt
  while IFS= read -r line; do
    test=$(echo "$line" | awk '{print $2}')
    echo kill -9 "$test"
    $ssh "$TL_USER"@"$1" kill -9 "$test" &
  done < /tmp/process_list1_"$1".txt
  sleep 3
  $ssh "$TL_USER"@"$1" "ps -edf | grep tcpdump | grep sosReport | grep -v bash" > /tmp/process_list2_"$1".txt
  while IFS= read -r line; do
    test=$(echo "$line" | awk '{print $2}')
    echo kill -9 "$test" again
    $ssh "$TL_USER"@"$1" kill -9 "$test" &
  done < /tmp/process_list2_"$1".txt
  sleep 3
  $ssh "$TL_USER"@"$1" "ps -edf | grep tcpdump | grep sosReport | grep -v bash" > /tmp/process_list3_"$1".txt
  while IFS= read -r line; do
    test=$(echo "$line" | awk '{print $2}')
    echo kill -9 "$test" once more...
    $ssh "$TL_USER"@"$1" kill -9 "$test" &
  done < /tmp/process_list3_"$1".txt
}

function help()
{
  echo
  echo "Usage: $0 [-h] [-o] "
  echo "Please don't forget to update sosReport.cfg first"
  echo  "  -o for disabling automatic log collection with sosReport : $0 -o"
  echo -e "\t -cp Copy the logs of other gnb logs in a multi-gnb secanrio : $0 -cp"
  echo "\t -t Execute the script with functions of gnb only or ap only : $0 -t GNB or $0 -t AP"

}

function mirroring_HWAPI_stop()
{
  $ssh "$TL_USER"@"$1" "python3 /ffs/run/config/scripts/gnbMirroring.py -f SendApiInetMirroringStopReq"
}

while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
    -h | --help) help; exit 0;;
    -o| --only) LOG_COLLECTION_DISABLED=1
        echo "disabling automatic log collection with sosReport";;
    -cp | --cplogs)
      CP_LOG=1
      echo "Copy other bts log enabled: $CP_LOG";;
    -t | --type) shift
      EXE_TYPE=$(echo "$1" | cut -f 2 -d '=')
      echo "Execution type set to: $EXE_TYPE";;
    *) echo "Unsupported option"
    help
    exit 1;;
  esac; shift;
done

echo "------------ Update ssh config ------------"
update_ssh_config

if [[ -z "$EXE_TYPE" ]] || [[ "$EXE_TYPE" == "GNB" ]];then
  if [ "$GNB_LOG" != "false" ]; then
    find_conf "$BTS_IP_1" GNB
  fi
fi

if [[ -z "$EXE_TYPE" ]] || [[ "$EXE_TYPE" == "AP" ]];then
  find_conf "$IPHY_FCT_IP_1" AP
fi

echo "------------ Stopping AP tcpdumps And Copy pcap.gz-files ------------"
#sudo killall tcpdump
if [[ -z "$EXE_TYPE" ]] || [[ "$EXE_TYPE" == "AP" ]];then
  kill_pcap_process "$IPHY_FCT_IP_1"
  kill_bip_pcap_process "$IPHY_FCT_IP_1"
fi

if [[ -z "$EXE_TYPE" ]] || [[ "$EXE_TYPE" == "GNB" ]];then
  if [ "$GNB_LOG" != "false" ]; then
    kill_pcap_process "$BTS_IP_1"
    kill_bip_pcap_process "$BTS_IP_1"
#  else
#    python3 vran_log.py L1 stop
#    python3 vran_log.py L2_HI stop
#    python3 vran_log.py L2_RT stop
  fi
fi

echo "------------ Stop Mirroring AP ------------"
if [[ -z "$EXE_TYPE" ]] || [[ "$EXE_TYPE" == "AP" ]];then
  mirroring_HWAPI_stop "$IPHY_FCT_IP_1"
fi

if [[ -z "$EXE_TYPE" ]] || [[ "$EXE_TYPE" == "GNB" ]];then
  if [ "$GNB_LOG" != "false" ]; then
    echo "------------ Stop Mirroring GNB ------------"
    mirroring_HWAPI_stop "$BTS_IP_1"
  fi
fi


if [[ -z "$EXE_TYPE" ]] || [[ "$EXE_TYPE" == "AP" ]];then
  echo "------------ Disabling Port Mirroring AP ------------"
  disablePortMirroring "$IPHY_FCT_IP_1"
fi

if [[ -z "$EXE_TYPE" ]] || [[ "$EXE_TYPE" == "GNB" ]];then
  if [ "$GNB_LOG" != "false" ]; then
    echo "------------ Disabling Port Mirroring GNB ------------"
    disablePortMirroring "$BTS_IP_1"
  fi
fi

#if [ "$LOG_COLLECTION_DISABLED" != "1" ]; then
#  echo "------------ Creating sosReport ------------"
#  /bin/bash "$WORK_DIR"/sosReport_ASIL.sh -t "$EXE_TYPE" -cp
#fi
