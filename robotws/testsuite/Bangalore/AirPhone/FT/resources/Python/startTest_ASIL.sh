#!/bin/bash

######################################################################################################################
# Script to enable mirroring and start tcpdump on both AP and GNB sides :
# . AP / ASIL+ABIO or ASOE
# . GNB / ASIK+ABIL or ASIB+ABIL or ASIB+ABIO/ABIN or ASIL+ABIO/ABIN or ASOE or ASIM+ABIP or ASIM+ABIO/ABIN
# Configurations mixing different BB types like ABIO+ABIP are not supported
# vRAN is also supported in front of AP / ASIL+ABIO or ASOE but without gNB tcpdump
# It uses the gnbMirroring.sh tool (\\eseefsn50.emea.nsn-net.net\rotta4internal\5G_3\Oulu\juhakang\tools\gnbMirroring)
# More info at https://confluence.int.net.nokia.com/pages/viewpage.action?spaceKey=CV&title=gNB+Mirroring
# Script used in combination with stopTest_ASIL.sh tool that stops tcpdump and collect traces (calling sosReport_ASIL.sh)
# Script called by ../startTest.sh (from eg /opt/iphy/latest/)
# Note : gnbMirroring*.sh scripts stored in gerrit may not be the latest available in rotta
# Note : gnbMirroring.sh is dynamically updated to add option "-z gzip" to BIP tcpdump
# Note : gnbMirroringConfig.sh is dynamically updated to reflect the AP and GNB BB boards configuration
# Note : gnbMirroring.sh does not support ASOE and uses lfs-nw_switch-mirror-tool.sh for ASIB+ABIO/ABIN or ASIL+ABIO/ABIN
#        but the lfs script should be removed after the introduction of feature CB008729 so gnbMirroring.sh is replaced
#        by a new script gnbMirroring.py using the MCU HWAPI functions implemented for CB008729 for ASIB+ABIO/ABIN or
#        or ASIL+ABIO/ABIN or ASOE, or ASIM+ABIP
#        gnbMirroring.sh does not use lfs-nw_switch-mirror-tool.sh for ASIK+ABIL
# Note : gnbMirroring.sh is not applicable to ASIM
# WTS pcap traces is for further study
######################################################################################################################

WORK_DIR=$(dirname "$0")
CONF_FILE=$WORK_DIR/../sosReport.cfg

MIRROR_METHOD=X
AP_MIRROR_METHOD=X
GNB_MIRROR_METHOD=X

AP_CTRL=none
AP_BSH_1=none
AP_BSH_2=none
AP_BSH_3=none
AP_slots=none
AP_slots_nb=none

GNB_CTRL=none
GNB_BSH_1=none
GNB_BSH_2=none
GNB_BSH_3=none
GNB_slots=none
GNB_slots_nb=none

GNB_LOG=true

function help()
{
cat <<EOF

  Prerequisites:
  syntax : $0 [-c] [-mM]
   -c or --chkMirroring : Check if a new version of gnbMirroring is available
   -mM or --mirroringMethod : Mirroring method (gnbMirroring.py (for ASIL+ABION or ASIB+ABION or ASOE or ASIM+ABIP) or gnbMirroring.sh)
   no mirroringMethod implemented for ASIM+ABIO
   mirroringMethod is a temporary argument used until gnbMirroring.sh method is obsolete (i.e. until lfs-nw_switch-mirror-tool.sh removal and ABIL is no more used)
   -t Execute the script with functions of gnb only or ap only : $0 -t GNB or $0 -t AP
EOF
}

while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do case $1 in
    -h | --help) help; exit 0;;
    -c | --chkMirroring) CHK_GNBMIRRORING_VERSION=1
       echo "$(tput setaf 6)Check if a new version of gnbMirroring is available$(tput sgr 0)";;
    -mM=?* | --mirroringMethod=?*) MIRROR_METHOD=$(echo "$1" | cut -f 2 -d '=');;
    -t | --type) shift
      EXE_TYPE=$(echo "$1" | cut -f 2 -d '=')
      echo "Execution type set to: $EXE_TYPE";;
    *) echo "Unexpected arg: $1"; help;;
  esac; shift;
done

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
      echo "$(tput setaf 6)Classical gNB IP address $var not filled in $CONF_FILE$(tput sgr 0)"
      echo "$(tput setaf 6)Script carries on assuming vRAN gNB or DUsim$(tput sgr 0)"
      BTS_IP="192.168.255.129"
      GNB_LOG="false"
    fi
    sshpass -p "${PASSWORD}" ssh-copy-id -i "$PRIVATE_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o CheckHostIP=no -o ConnectTimeout=5s "$TL_USER"@"$IPHY_FCT_IP_1"
  fi
}

function wait_for_interfaces()
{
  if [ "$2" == "GNB" ]; then
    board_type=$GNB_CTRL
  elif [ "$2" == "AP" ]; then
    board_type=$AP_CTRL
  fi
  if [ "$board_type" == "ASIL" ]; then
    test_slot=0
    for bsh in 1 2 3
      do
        var=$2_BSH_$bsh
        fsp=${!var}
        if [ "$fsp" != "none" ]; then
          test_slot=$bsh
        fi
      done
    while ! $ssh "$TL_USER"@"$1" bsh "$test_slot":0 ifconfig etha01.212  2>/dev/null ; do sleep 2 ; done
    while ! $ssh "$TL_USER"@"$1" bsh "$test_slot":1 ifconfig etha01.212  2>/dev/null ; do sleep 2 ; done
    while ! $ssh "$TL_USER"@"$1" ifconfig etha01.212  2>/dev/null ; do sleep 2 ; done
  elif [[ "$board_type" =~ ^ASO.*$ ]]; then
    while ! $ssh "$TL_USER"@"$1" ifconfig etha01.212  2>/dev/null ; do sleep 2 ; done
  elif [ "$board_type" == "ASIM" ]; then
    while ! $ssh "$TL_USER"@"$1" ifconfig etha01.212  2>/dev/null ; do sleep 2 ; done
  else
    while ! $ssh "$TL_USER"@"$1" bsh 1:2 ifconfig rlan0 2>/dev/null ; do sleep 2 ; done
  fi
}

function mirroring_prep()
{
  $ssh "$TL_USER"@"$1" "rm -rf /ffs/run/config/scripts"
  $ssh "$TL_USER"@"$1" "mkdir -p /ffs/run/config/scripts"
  $scp "$WORK_DIR"/gnbMirroring.sh "$TL_USER"@"$1"://ffs/run/config/scripts/
  if [ "$2" == "AP" ]; then
    $scp "$WORK_DIR"/gnbMirroringConfig_AP.sh "$TL_USER"@"$1":/ffs/run/config/scripts/gnbMirroringConfig.sh
    $scp "$WORK_DIR"/gnbMirroring_AP.sh "$TL_USER"@"$1":/ffs/run/config/scripts/gnbMirroring.sh
  else
    $scp "$WORK_DIR"/gnbMirroringConfig_GNB.sh "$TL_USER"@"$1":/ffs/run/config/scripts/gnbMirroringConfig.sh
    $scp "$WORK_DIR"/gnbMirroring_GNB.sh "$TL_USER"@"$1":/ffs/run/config/scripts/gnbMirroring.sh
  fi
  $scp "$WORK_DIR"/gnbMirroring.py "$TL_USER"@"$1":/ffs/run/config/scripts/gnbMirroring.py
  $ssh "$TL_USER"@"$1" "chmod 777 /ffs/run/config/scripts/*.py"
  $ssh "$TL_USER"@"$1" "chmod 777 /ffs/run/config/scripts/*.sh"
}

function mirroring_HWAPI_exec()
{
  slots_nb=$2"_slots_nb"
  slots=$2"_slots"
  hw_ctrl=$2"_CTRL"
  if [ "${!hw_ctrl}" == "ASOE" ]; then
    cmd="python3 /ffs/run/config/scripts/gnbMirroring.py -t 0 -s 1"
  else
    cmd="python3 /ffs/run/config/scripts/gnbMirroring.py -t 0 ${!slots_nb} ${!slots}"
  fi
  $ssh "$TL_USER"@"$1" $cmd

  if [ "$AP_BSH_1" == "ABIO" ] || [ "$AP_BSH_2" == "ABIO" ] || [ "$AP_BSH_3" == "ABIO" ] || [ "$AP_CTRL" == "ASOE" ] || [ "$AP_BSH_1" == "ABIP" ] || [ "$AP_BSH_2" == "ABIP" ] || [ "$AP_BSH_3" == "ABIP" ]; then

    # try to get the mirroring interface used by gnbMirroring.py to dump the BIP messages (10*30M pcap files before stopTest.sh execution that will not be collected by sosReport.sh)

    test_day=$($ssh "$TL_USER"@"$1" "date \"+%Y%m%d\"")
    cmd="ps -aux | grep CCSPacketCapture | awk -F'_${test_day}' '{print \$1}'"
    $ssh "$TL_USER"@"$1" "$cmd" > /tmp/test.txt
    itf=$(grep -w CCSPacketCapture /tmp/test.txt | awk -F'mirroring_L2L1_' '{print $2}')
    echo "mirroring interface is $itf"

    # additional tcpdump to capture the ${BIP_NUMBER_OF_FILES}*${BIP_FILE_SIZE_MBYTES} pcap files after startTest.sh execution
    # and the ${BIP_NUMBER_OF_FILES}*${BIP_FILE_SIZE_MBYTES} pcap files before stopTest.sh execution

    if [ "$2" == "AP" ]; then
      $ssh "$TL_USER"@"$1" bsh 0:0 tcpdump -i $itf -s 262144 -C ${BIP_FILE_SIZE_MBYTES} -W ${BIP_NUMBER_OF_FILES} -z gzip -n not arp -w /tmp/sosReport/UEAPP_tcpdump_L2L1_bip_filtering_off.pcap.gz > /dev/null 2>&1 &
    else
      $ssh "$TL_USER"@"$1" bsh 0:0 tcpdump -i $itf -s 262144 -C ${BIP_FILE_SIZE_MBYTES} -W ${BIP_NUMBER_OF_FILES} -z gzip -n not arp -w /tmp/sosReport/bts_tcpdump_L2L1_bip_filtering_off.pcap.gz > /dev/null 2>&1 &
    fi
  else
    size_h=`$ssh "$TL_USER"@"$1" grep -w 0x3F007C /ffs/run/swconfig.txt | awk -F'0x3F007C=' '{print \$2}'`
    if [ "$size_h" == "" ] ; then
      echo "$(tput setaf 6)Up to 300 Mbytes of pcap files will be collected. If higher size is requested :"
    else
      printf -v size_d '%d' $size_h
      echo "$(tput setaf 6)Up to $size_d Mbytes of pcap files will be collected. If higher size is requested :"
    fi
      size_d=$((${BIP_FILE_SIZE_MBYTES} * ${BIP_NUMBER_OF_FILES}))
      printf -v size_h '%x' $size_d
      echo ">> Add radparam 0x3F007C to $2 /ffs/run/swconfig.txt file with the value set to the requested size in hexa (e.g. 0x$size_h,  0xC00 max)"
      echo ">> and reboot $2 ...$(tput sgr 0)"
  fi
}

function mirroring_exec()
{
  $ssh "$TL_USER"@"$1" "nohup /ffs/run/config/scripts/gnbMirroring.sh > /dev/null 2>&1 &"
}

function mirroring_rest()
{
  if [ "$2" == "AP" ]; then
    sed -i "s/\/tmp\/sosReport\/UEAPP_tcpdump_L2L1_bip_filtering/\/tmp\/UEAPP_tcpdump_L2L1_bip_filtering/g" "$WORK_DIR"/gnbMirroring_AP.sh
    $scp "$WORK_DIR"/gnbMirroring_AP.sh "$TL_USER"@"$1":/ffs/run/config/scripts/gnbMirroring.sh
  else
    sed -i "s/\/tmp\/sosReport\/BTS_tcpdump_L2L1_bip_filtering/\/tmp\/BTS_tcpdump_L2L1_bip_filtering/g" "$WORK_DIR"/gnbMirroring_GNB.sh
    $scp "$WORK_DIR"/gnbMirroring_GNB.sh "$TL_USER"@"$1":/ffs/run/config/scripts/gnbMirroring.sh
  fi
}

function startTcpDump()
{
  # Max 10 chunks of 100 MB each
  CHUNK_SIZE=100
  CHUNK_MAX_COUNT=10
  TCPDUMP_OPTS="-U -s 65535 -n -C ${CHUNK_SIZE} -W ${CHUNK_MAX_COUNT} -z gzip -w "
#  sudo tcpdump -i eth4 ${TCPDUMP_OPTS} /tmp/wts.pcap.gz &
  sleep 2

  if [[ -z "$EXE_TYPE" ]] || [[ "$EXE_TYPE" == "AP" ]];then
    if [ "$AP_CTRL" == "ASIL" ] || [ "$AP_CTRL" == "ASOE" ]; then
      $ssh "$TL_USER"@"$IPHY_FCT_IP_1" "mkdir -p /tmp/sosReport"
      $ssh "$TL_USER"@"$IPHY_FCT_IP_1" "chmod -R 777 /tmp/sosReport"
      echo tcpdump -i etha01.212 sctp port 29211 ${TCPDUMP_OPTS} /tmp/sosReport/UEAPP_"$AP_CTRL"_syscom.pcap.gz
      $ssh "$TL_USER"@"$IPHY_FCT_IP_1" tcpdump -i etha01.212 sctp port 29211 "${TCPDUMP_OPTS}" /tmp/sosReport/UEAPP_"$AP_CTRL"_syscom.pcap.gz &
      sleep 2
    fi
    for bsh in 1 2 3
      do
        var=AP_BSH_$bsh
        fsp=${!var}
        if [ "$fsp" == "ABIO" ]; then
          echo start tcpdump on AP - "$fsp"
          $ssh "$TL_USER"@"$IPHY_FCT_IP_1" mkdir -p "${LOG_DIR_ON_DEVICE}"/sosReport
          $ssh "$TL_USER"@"$IPHY_FCT_IP_1" chmod -R 777 "${LOG_DIR_ON_DEVICE}"/sosReport
          echo bsh "$bsh":0 : tcpdump -i etha01.212 sctp port 29211 "${TCPDUMP_OPTS}" "${LOG_DIR_ON_DEVICE}"/sosReport/UEAPP_abio_fsp"$bsh"_syscom.pcap.gz
          $ssh "$TL_USER"@"$IPHY_FCT_IP_1" bsh "$bsh":0 tcpdump -i etha01.212 sctp port 29211 "${TCPDUMP_OPTS}" "${LOG_DIR_ON_DEVICE}"/sosReport/UEAPP_abio_fsp"$bsh"_syscom.pcap.gz &
          sleep 1
          $ssh "$TL_USER"@"$IPHY_FCT_IP_1" bsh "$bsh":1 mkdir -p /tmp/sosReport
          $ssh "$TL_USER"@"$IPHY_FCT_IP_1" bsh "$bsh":1 chmod -R 777 /tmp/sosReport
          echo bsh "$bsh":1 : tcpdump -i etha01.212 sctp port 29211 "${TCPDUMP_OPTS}" /tmp/sosReport/UEAPP_abio_fsp"$bsh"_lokiA_syscom.pcap.gz
          $ssh "$TL_USER"@"$IPHY_FCT_IP_1" bsh "$bsh":1 tcpdump -i etha01.212 sctp port 29211 "${TCPDUMP_OPTS}" /tmp/sosReport/UEAPP_abio_fsp"$bsh"_lokiA_syscom.pcap.gz &
          sleep 1
          $ssh "$TL_USER"@"$IPHY_FCT_IP_1" bsh "$bsh":2 mkdir -p /tmp/sosReport
          $ssh "$TL_USER"@"$IPHY_FCT_IP_1" bsh "$bsh":2 chmod -R 777 /tmp/sosReport
          echo bsh "$bsh":2 : tcpdump -i etha01.212 sctp port 29211 "${TCPDUMP_OPTS}" /tmp/sosReport/UEAPP_abio_fsp"$bsh"_lokiB_syscom.pcap.gz
          $ssh "$TL_USER"@"$IPHY_FCT_IP_1" bsh "$bsh":2 tcpdump -i etha01.212 sctp port 29211 "${TCPDUMP_OPTS}" /tmp/sosReport/UEAPP_abio_fsp"$bsh"_lokiB_syscom.pcap.gz &
          sleep 1
        fi
      done
  fi

  if [[ -z "$EXE_TYPE" ]] || [[ "$EXE_TYPE" == "GNB" ]];then
    if [ "$GNB_LOG" != "false" ]; then
      $ssh "$TL_USER"@"$BTS_IP_1" "mkdir -p /tmp/sosReport"
      $ssh "$TL_USER"@"$BTS_IP_1" "chmod -R 777 /tmp/sosReport"
      for bsh in 1 2 3
        do
          var=GNB_BSH_$bsh
          fsp=${!var}
          if [ "$fsp" == "ABIO" ] || [ "$fsp" == "ABIN" ]; then
            echo "start tcpdump on GNB ($fsp)"
            $ssh "$TL_USER"@"$BTS_IP_1" bsh "$bsh":1 mkdir -p /tmp/sosReport
            $ssh "$TL_USER"@"$BTS_IP_1" bsh "$bsh":1 chmod -R 777 /tmp/sosReport
            echo bsh "$bsh":1 : tcpdump -i etha01.212 sctp port 29211 "${TCPDUMP_OPTS}" /tmp/sosReport/BTS_"$fsp"_fsp"$bsh"_lokiA_syscom.pcap.gz
            $ssh "$TL_USER"@"$BTS_IP_1" bsh "$bsh":1 tcpdump -i etha01.212 sctp port 29211 "${TCPDUMP_OPTS}" /tmp/sosReport/BTS_"$fsp"_fsp"$bsh"_lokiA_syscom.pcap.gz &
            sleep 1
            if [ "$fsp" == "ABIO" ]; then
              $ssh "$TL_USER"@"$BTS_IP_1" bsh "$bsh":2 mkdir -p /tmp/sosReport
              $ssh "$TL_USER"@"$BTS_IP_1" bsh "$bsh":2 chmod -R 777 /tmp/sosReport
              echo bsh "$bsh":2 : tcpdump -i etha01.212 sctp port 29211 "${TCPDUMP_OPTS}" /tmp/sosReport/BTS_"$fsp"_fsp"$bsh"_lokiB_syscom.pcap.gz
              $ssh "$TL_USER"@"$BTS_IP_1" bsh "$bsh":2 tcpdump -i etha01.212 sctp port 29211 "${TCPDUMP_OPTS}" /tmp/sosReport/BTS_"$fsp"_fsp"$bsh"_lokiB_syscom.pcap.gz &
            fi
            sleep 1
          elif [ "$fsp" == "ABIL" ]; then
            echo tcpdump -i ethbp1 "${TCPDUMP_OPTS}" /tmp/BTS_fsp"$bsh"_traffic_L1L2_ethbp1.pcap.gz
            $ssh "$TL_USER"@"$BTS_IP_1" bsh "$bsh":1 mkdir -p /tmp/sosReport
            $ssh "$TL_USER"@"$BTS_IP_1" bsh "$bsh":1 chmod -R 777 /tmp/sosReport
            $ssh "$TL_USER"@"$BTS_IP_1" bsh "$bsh":1 tcpdump -i ethbp1 "${TCPDUMP_OPTS}" /tmp/sosReport/BTS_fsp"$bsh"_traffic_L1L2_ethbp1.pcap.gz > /dev/null 2>&1 &
            $ssh "$TL_USER"@"$BTS_IP_1" bsh "$bsh":2 mkdir -p /tmp/sosReport
            $ssh "$TL_USER"@"$BTS_IP_1" bsh "$bsh":2 chmod -R 777 /tmp/sosReport
            $ssh "$TL_USER"@"$BTS_IP_1" bsh "$bsh":2 tcpdump -i rlan0  "${TCPDUMP_OPTS}" /tmp/sosReport/BTS_fsp"$bsh"_traffic_rlan0_FPGA.pcap.gz &
          fi
        done
    fi
  fi
}

function check_files()
{
  if [ -d /tmp/clone_repo ]; then
      rm -rf /tmp/clone_repo
  fi

  # Check if sosReport is fully installed
  if [ ! -f "$WORK_DIR"/gnbMirroring.py ] || [ ! -f "$WORK_DIR"/gnbMirroring.sh ] || [ ! -f "$WORK_DIR"/gnbMirroringConfig.sh ] || [ ! -f "$WORK_DIR"/sosReport_ASIL.sh ]; then
    echo FILE "$WORK_DIR"/gnbMirroring*.* or sosReport_ASIL.sh MISSING - NEED TO GET THEM
    git clone --quiet --depth=1 "https://gerrit.ext.net.nokia.com/gerrit/MN/LTE/TOOLS/WTS/wts" /tmp/clone_repo
    if [ ! -f "$WORK_DIR"/gnbMirroring.py ]; then
      cp /tmp/clone_repo/src/linux/tools/sosReport/sosReport_ASIL/gnbMirroring.py "$WORK_DIR"/
    fi
    if [ ! -f "$WORK_DIR"/gnbMirroring.sh ]; then
      cp /tmp/clone_repo/src/linux/tools/sosReport/sosReport_ASIL/gnbMirroring.sh "$WORK_DIR"/
    fi
    if [ ! -f "$WORK_DIR"/gnbMirroringConfig.sh ]; then
      cp /tmp/clone_repo/src/linux/tools/sosReport/sosReport_ASIL/gnbMirroringConfig.sh "$WORK_DIR"/
    fi
    if [ ! -f "$WORK_DIR"/sosReport_ASIL.sh ]; then
      cp /tmp/clone_repo/src/linux/tools/sosReport/sosReport_ASIL/sosReport_ASIL.sh "$WORK_DIR"/
    fi
    rm -rf /tmp/clone_repo
  fi

  # Check if local gnbMirroring version is the latest one available in gitLab and, if not, propose to update it
  git clone --quiet --depth=1 "https://gitlabe2.ext.net.nokia.com/juhakang/tools.git" /tmp/clone_repo
  test=$(grep -w VERSION_STRING= "$WORK_DIR"/gnbMirroring.sh)
  test=${test:15}
  version_vm=${test//\'/}
  test=$(grep -w VERSION_STRING= /tmp/clone_repo/gnbMirroring/gnbMirroring.sh)
  test=${test:15}
  version_repo=${test//\'/}
  if [ "$version_vm" != "$version_repo" ] ; then
    if [ "$CHK_GNBMIRRORING_VERSION" == "1" ] ; then
      echo "$(tput setaf 1)$(tput setab 7)!!! The gnbMirroring version $version_vm used by sosReport is not the latest version $version_repo available on gitlab !!!$(tput sgr 0)"
      while true; do
        read -p "Do you want to update it on your VM ? (y/n) " answer
        case $answer in
          [Yy]* ) mv "$WORK_DIR"/gnbMirroring.sh "$WORK_DIR"/gnbMirroring_$version_vm.sh
                  mv "$WORK_DIR"/gnbMirroringConfig.sh "$WORK_DIR"/gnbMirroringConfig_"$version_vm".sh
                  cp /tmp/clone_repo/gnbMirroring/gnbMirroring* "$WORK_DIR"/;
                  echo "$(tput setaf 6)Older gnbMirroring version saved as gnbMirroring_"$version_vm".sh and gnbMirroringConfig_"$version_vm".sh under "$(dirname $(realpath $0))"$(tput sgr 0)"
                  break;;
          [Nn]* ) break;;
          * ) echo "Please type Y or N";;
        esac
      done
    else
      echo "$(tput setaf 3)!!! The gnbMirroring.sh version $version_vm used by sosReport is not the latest version $version_repo available on gitlab !!!$(tput sgr 0)"
    fi
  else
    echo "$(tput setaf 6)The gnbMirroring.sh version used by sosReport is $version_vm (latest version available on gitlab)$(tput sgr 0)"
  fi
  rm -rf /tmp/clone_repo

  # Configure gnbMirroring for both gNB and Airphone and apply patches
  for slot in 1 2 3 5 6 7
    do
      sed -i "s/BB_SLOT_$slot='true/BB_SLOT_$slot='false/g" "$WORK_DIR"/gnbMirroringConfig.sh
    done
  cp "$WORK_DIR"/gnbMirroringConfig.sh "$WORK_DIR"/gnbMirroringConfig_AP.sh
  cp "$WORK_DIR"/gnbMirroringConfig.sh "$WORK_DIR"/gnbMirroringConfig_GNB.sh
  sed -i "s/$FILTERING.pcap /$FILTERING.pcap.gz /g" "$WORK_DIR"/gnbMirroring.sh
  sed -i "s/NUMBER_OF_FILES -w/NUMBER_OF_FILES -z gzip -n not arp -w/g" "$WORK_DIR"/gnbMirroring.sh
  cp "$WORK_DIR"/gnbMirroring.sh "$WORK_DIR"/gnbMirroring_AP.sh
  cp "$WORK_DIR"/gnbMirroring.sh "$WORK_DIR"/gnbMirroring_GNB.sh
  sed -i "s/\/tmp\/tcpdump_L2L1_bip_filtering/\/tmp\/sosReport\/UEAPP_tcpdump_L2L1_bip_filtering/g" "$WORK_DIR"/gnbMirroring_AP.sh
  sed -i "s/\/tmp\/tcpdump_L2L1_bip_filtering/\/tmp\/sosReport\/BTS_tcpdump_L2L1_bip_filtering/g" "$WORK_DIR"/gnbMirroring_GNB.sh
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
      MIRRORING_CONF_FILE="$WORK_DIR"/gnbMirroringConfig_AP.sh
      AP_CTRL=$test
    fi
  elif [ "$test" = "" ]; then
    echo "$(tput setaf 3)No info available for Classical $2 HW$(tput sgr 0)"
    echo "$(tput setaf 3)No classical $2 logs will be collected$(tput sgr 0)"
    GNB_LOG="false"
    return
  else
    echo "$2" Control Board is "$test"
    MIRRORING_CONF_FILE="$WORK_DIR"/gnbMirroringConfig_GNB.sh
    GNB_CTRL=$test
  fi

  tmp_slot_nb=0
  tmp_slots=""
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
        let "tmp_slot_nb=tmp_slot_nb+1"
        if [ "$slot" == "4" ] || [ "$slot" == "5" ] || [ "$slot" == "6" ] ; then
          let "slot=slot+1"
        fi
        tmp_slots=$tmp_slots" --s"$tmp_slot_nb" "$slot
        if [ "$slot" == "1" ]; then
          sed -i "s/BB_SLOT_1='false/BB_SLOT_1='true/g" "$MIRRORING_CONF_FILE"
        elif [ "$slot" == "2" ]; then
          sed -i "s/BB_SLOT_2='false/BB_SLOT_2='true/g" "$MIRRORING_CONF_FILE"
        elif [ "$slot" == "3" ]; then
          sed -i "s/BB_SLOT_3='false/BB_SLOT_3='true/g" "$MIRRORING_CONF_FILE"
        elif [ "$slot" == "5" ]; then
          sed -i "s/BB_SLOT_5='false/BB_SLOT_5='true/g" "$MIRRORING_CONF_FILE"
        elif [ "$slot" == "6" ]; then
          sed -i "s/BB_SLOT_6='false/BB_SLOT_6='true/g" "$MIRRORING_CONF_FILE"
        elif [ "$slot" == "7" ]; then
          sed -i "s/BB_SLOT_7='false/BB_SLOT_7='true/g" "$MIRRORING_CONF_FILE"
        fi
      fi
    done
  let "tmp=tmp_slot_nb+1"
  for ((i=tmp ; i<=3 ; i++))
    do
	  tmp_slots=$tmp_slots" --s"$i" 0"
	done
  if [ "$2" == "AP" ]; then
    AP_slots=$tmp_slots
    AP_slots_nb="-s "$tmp_slot_nb
  else
    GNB_slots=$tmp_slots
    GNB_slots_nb="-s "$tmp_slot_nb
  fi
}

if [ -f "$CONF_FILE" ]; then
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
scp="scp -qr -B -o StrictHostkeyChecking=no "

echo "------------ Update ssh config ------------"
update_ssh_config

check_files

if [[ -z "$EXE_TYPE" ]] || [[ "$EXE_TYPE" == "GNB" ]];then
  if [ "$GNB_LOG" != "false" ]; then
    find_conf "$BTS_IP_1" GNB
  fi
fi

if [[ -z "$EXE_TYPE" ]] || [[ "$EXE_TYPE" == "AP" ]];then
  find_conf "$IPHY_FCT_IP_1" AP
fi

if [ "$MIRROR_METHOD" == "X" ] || [ "$MIRROR_METHOD" == "PY" ] || [ "$MIRROR_METHOD" == "SH" ] ; then
  AP_MIRROR_METHOD=$MIRROR_METHOD
  if [ "$AP_MIRROR_METHOD" == "X" ] ; then
    AP_MIRROR_METHOD=PY
    echo "$(tput setaf 6)Mirroring method with gnbMirroring.py applied on AP - see help$(tput sgr 0)"
  fi
  if [ "$AP_MIRROR_METHOD" == "SH" ] && [ "$AP_CTRL" == "ASOE" ] ; then
    AP_MIRROR_METHOD=PY
    echo "$(tput setaf 6)Mirroring method with gnbMirroring.py applied on AP - see help$(tput sgr 0)"
  fi

  GNB_MIRROR_METHOD=$AP_MIRROR_METHOD
  if [ "$GNB_MIRROR_METHOD" == "PY" ] ; then
    if [ "$GNB_BSH_1" == "ABIL" ] || [ "$GNB_BSH_2" == "ABIL" ] || [ "$GNB_BSH_3" == "ABIL" ] ; then
      GNB_MIRROR_METHOD=SH
      echo "$(tput setaf 6)Old mirroring method with gnbMirroring.sh applied on GNBoABIL - see help$(tput sgr 0)"
    fi
  elif [ "$GNB_MIRROR_METHOD" == "SH" ] && [ "$GNB_CTRL" == "ASOE" ] ; then
    GNB_MIRROR_METHOD=PY
    echo "$(tput setaf 6)Mirroring method with gnbMirroring.py applied on GNBoASOE - see help$(tput sgr 0)"
  elif [ "$GNB_MIRROR_METHOD" == "SH" ] && [ "$GNB_CTRL" == "ASIM" ] ; then
    GNB_MIRROR_METHOD=PY
    echo "$(tput setaf 6)Mirroring method with gnbMirroring.py applied on GNBoASOE - see help$(tput sgr 0)"
  elif [ "$MIRROR_METHOD" == "X" ] ; then
    echo "$(tput setaf 6)Mirroring method with gnbMirroring.py applied on GNB - see help$(tput sgr 0)"
  fi

else
  echo "$(tput setaf 1)!!! THE MIRRORING METHOD REQUIRED (-mM option) IS NOT IMPLEMENTED !!!$(tput sgr 0)"
  echo "$(tput setaf 1)!!! Please use -mM=SH for gnbMirroring.sh or -mM=PY for gnbMirroring.py $(tput sgr 0)"
  exit
fi

echo "------------ Starting PCAPS ------------"
if [[ -z "$EXE_TYPE" ]] || [[ "$EXE_TYPE" == "GNB" ]];then
  if [ "$GNB_LOG" != "false" ]; then
    $ssh "$TL_USER"@"$BTS_IP_1" "rm -rf $LOG_DIR_ON_DEVICE"
    $ssh "$TL_USER"@"$BTS_IP_1" "mkdir -p $LOG_DIR_ON_DEVICE"
  fi
fi
if [[ -z "$EXE_TYPE" ]] || [[ "$EXE_TYPE" == "AP" ]];then
  $ssh "$TL_USER"@"$IPHY_FCT_IP_1" "rm -rf $LOG_DIR_ON_DEVICE"
  $ssh "$TL_USER"@"$IPHY_FCT_IP_1" "mkdir -p $LOG_DIR_ON_DEVICE"
fi


if [[ -z "$EXE_TYPE" ]] || [[ "$EXE_TYPE" == "GNB" ]];then
  if [ "$GNB_LOG" != "false" ]; then
    echo "------------ Wait for GNB BB board being ready ------------"
    wait_for_interfaces "$BTS_IP_1" GNB
  fi
fi
if [[ -z "$EXE_TYPE" ]] || [[ "$EXE_TYPE" == "AP" ]];then
  echo "------------ Wait for AP BB board being ready ------------"
  wait_for_interfaces "$IPHY_FCT_IP_1" AP
fi

echo "------------ Starting tcpdump ------------"
startTcpDump
sleep 5


if [[ -z "$EXE_TYPE" ]] || [[ "$EXE_TYPE" == "GNB" ]];then
  if [ "$GNB_LOG" != "false" ]; then
    mirroring_prep "$BTS_IP_1" GNB
#  else
#    mkdir -p /tmp/vran_log
#    rm -rf /tmp/vran_log
#    python3 vran_log.py L1 mirror true
#    python3 vran_log.py L2_HI mirror
#    python3 vran_log.py L2_RT mirror
#    python3 vran_log.py L1 start
#    python3 vran_log.py L2_HI start
#    python3 vran_log.py L2_RT start
  fi
  if [ "$GNB_MIRROR_METHOD" == "SH" ] && [ "$GNB_LOG" != "false" ] ; then
    echo "--- Enabling Port Mirroring on GNB using gnbMirroring.$(tput setaf 6)sh$(tput sgr 0) method ---"
    mirroring_exec "$BTS_IP_1" GNB
  fi
  if [ "$GNB_MIRROR_METHOD" == "PY" ] && [ "$GNB_LOG" != "false" ] ; then
    echo "--- Enabling Port Mirroring on GNB using gnbMirroring.$(tput setaf 6)py$(tput sgr 0) method ---"
    mirroring_HWAPI_exec "$BTS_IP_1" GNB
  fi
fi


if [[ -z "$EXE_TYPE" ]] || [[ "$EXE_TYPE" == "AP" ]];then
  mirroring_prep "$IPHY_FCT_IP_1" AP
  if [ "$AP_MIRROR_METHOD" == "SH" ]; then
    echo "--- Enabling Port Mirroring on AP using gnbMirroring.$(tput setaf 6)sh$(tput sgr 0) method ---"
    mirroring_exec "$IPHY_FCT_IP_1" AP
    echo Wait for mirroring completion
  fi
  if [ "$AP_MIRROR_METHOD" == "PY" ]; then
    echo "--- Enabling Port Mirroring on AP using gnbMirroring.$(tput setaf 6)py$(tput sgr 0) method ---"
    mirroring_HWAPI_exec "$IPHY_FCT_IP_1" AP
  fi
fi

if [ "$GNB_MIRROR_METHOD" == "SH" ] && [ "$GNB_LOG" != "false" ] || [ "$AP_MIRROR_METHOD" == "SH" ] ; then
  echo "$(tput setaf 1)Please reboot the gNB after this test if you want to start a new test with gnbMirroring.py method$(tput sgr 0)"
fi

if [[ -z "$EXE_TYPE" ]] || [[ "$EXE_TYPE" == "GNB" ]];then
  if [ "$GNB_MIRROR_METHOD" == "SH" ] && [ "$GNB_LOG" != "false" ] ; then
    sleep 5
    mirroring_rest "$BTS_IP_1" GNB
  fi
fi

if [[ -z "$EXE_TYPE" ]] || [[ "$EXE_TYPE" == "AP" ]];then
  if [ "$AP_MIRROR_METHOD" == "SH" ]; then
    mirroring_rest "$IPHY_FCT_IP_1" AP
  fi
fi

sleep 2

echo "------------ Done. You can now start your tests in egate ------------"
