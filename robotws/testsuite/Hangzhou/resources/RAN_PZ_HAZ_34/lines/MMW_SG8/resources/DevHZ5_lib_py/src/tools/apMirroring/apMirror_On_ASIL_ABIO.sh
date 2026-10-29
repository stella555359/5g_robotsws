#!/bin/bash 

WORK_DIR=$(dirname "$0")

IPHY_FCT_IP_1=192.168.200.1
LOG_DIR_ON_DEVICE="/ffs/run/config/toor4nsn/logs"
COMMON_DIR_ON_DEVICE="/ffs/run/config/toor4nsn/logs"
TL_USER="toor4nsn"
PASSWORD=oZPS0POrRieRtu


function find_conf()
{
  echo "------------ Find $2 HW configuration ------------"
  chk sysbshtopo > "$WORK_DIR"/test.txt
  test=$(grep -w ctrll "$WORK_DIR"/test.txt | awk '{print $4}')
  echo "test = $test"
  echo "$2" Control Board is "$test"
  if [ "$test" != "ASIL" ] && [ "$2" == "AP" ]; then
    echo ERROR: SCRIPT NOT APPLICABLE FOR "$2" on "$test"
    exit
  fi
  if [ "$test" = "" ] && [ "$2" = "GNB" ]; then
    echo "$(tput setaf 1)!!! WARNING: NO INFO AVAILABLE FOR $2 HW at $1 !!!$(tput sgr 0)"
    echo "$(tput setaf 1)!!! WARNING: NO $2 TCPDUMP WILL BE TRIGGERED !!!$(tput sgr 0)"
    GNB_LOG="false"
    break
  fi
  tmp_slot_nb=0
  tmp_slots=""
  for bsh in 1:0 2:0 3:0
    do
      slot=$(grep -w $bsh "$WORK_DIR"/test.txt | awk '{print $3}')
      slot=${slot:1:1}
      if [ "$slot" == "" ]; then
        echo no "$2" board found for bsh "$bsh"
      else
        board=$(grep -w $bsh "$WORK_DIR"/test.txt | awk '{print $4}')
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


find_conf "$IPHY_FCT_IP_1" AP

echo "AP_slots = $AP_slots"
echo "AP_slots_nb = $AP_slots_nb"

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
  echo "cmd = $cmd"
  $cmd
}

function start_tcpdump()
{
  tcpdump -vvv -i nac_eth3 -C 500 -W 10 -w /tmp/tcpdumpapL2L1_filtering_off.pcap
}

mirroring_HWAPI_exec "$IPHY_FCT_IP_1" AP
start_tcpdump