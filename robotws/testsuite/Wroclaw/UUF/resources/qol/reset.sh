#!/bin/bash
#Small script to trigger the reset.robot

#Set variables
BUILD=$1
AMOUNT=200
ID=$(sshpass -p oZPS0POrRieRtu ssh -q toor4nsn@192.168.255.129 cat /var/dt/module-identity/unit-id | tr -d '\0')
#Check active build
ACTIVE=$(sshpass -p oZPS0POrRieRtu ssh -q toor4nsn@192.168.255.129 ls /ffs/run/ | grep Target | grep -v .p7 | awk -F '_' '{print $2"_"$3"_"$4"_"$5"_"$6}' | awk -F '.' '{print $1 }')
#echo $ACTIVE
#Check if begins with SBTS00
ISTRUNK=$(echo $BUILD | cut -d'_' -f 1)
#Check if build is Trunk or not
ISTRUNKBUILD=$(echo $BUILD | cut -d'_' -f 3)
#Check requested soft
CHECKBUILD=$(echo $BUILD | cut -d'_' -f2-)
#Check if Active is Trunk or not
ISTRUNKACTIVE=$(echo $ACTIVE | cut -d'_' -f 3)
#Check Active soft
CHECKACTIVE=$(echo $ACTIVE | cut -d'_' -f2-)

#Set tags
GREEN='\e[32m'
RED='\e[31m'
BOLD='\e[1m'
NO_COLOR='\e[0m'
PRINT_INFO="${BOLD}[INFO]${NO_COLOR} "
PRINT_INPUT="${BOLD}[INPUT]${NO_COLOR} "
PRINT_OK="${GREEN}${BOLD}[OK]${NO_COLOR} "
PRINT_ERROR="${RED}${BOLD}[ERROR]${NO_COLOR} "

#Check if the build is correct
if [ ! $1 ]; then echo -e "$PRINT_ERROR Please provide the SW Build";
 exit 1
fi

#Check if Trunk resets are perfromed using SBTS00 and if build is the same as soft on active partition
if [[ $ISTRUNKBUILD == "9999" || $ISTRUNKBUILD == "9990" ]]; then
  if [[ "$ISTRUNK" = "SBTS00" ]]; then
    if [[ $CHECKBUILD == $CHECKACTIVE ]]; then
      echo -e "$PRINT_OK Active Build ${BOLD}${ACTIVE}${NO_COLOR} is the same as requested build ${BOLD}${BUILD}${NO_COLOR} Starting resets."
    else
      echo -e "$PRINT_ERROR Requested build: ${BOLD}${BUILD}${NO_COLOR} is different than build on active partition: ${BOLD}${ACTIVE}${NO_COLOR}"; exit 1
    fi
  else
    echo -e "$PRINT_ERROR Please check! Seems you are trying to run resets on Trunk soft as ${BOLD}${ISTRUNK}${NO_COLOR} instead of ${BOLD}SBTS00${NO_COLOR}"; exit 1
  fi
elif [[ $BUILD == $ACTIVE ]]; then
  echo -e "$PRINT_OK Active Build ${BOLD}${ACTIVE}${NO_COLOR} is the same as requested build ${BOLD}${BUILD}${NO_COLOR} Starting resets."
else
  echo -e "$PRINT_ERROR Requested build: ${BOLD}${BUILD}${NO_COLOR} is different than build on active partition: ${BOLD}${ACTIVE}${NO_COLOR} "; exit 1
fi
##Check if the amount is set in alias
if [[ $2 ]]; then
  AMOUNT=$2
fi
#Check if the amount is a number
re='^[0-9]+$'
if ! [[ $AMOUNT =~ $re ]] ; then
   echo -e "$PRINT_ERROR $BOLD${AMOUNT}$NO_COLOR is not a number" >&2; exit 1
fi

##Set the OPTION input
echo -e "$PRINT_INFO What type of reset would you like to perform ?\n$PRINT_INFO 1. Reset with HWF deletion \n$PRINT_INFO 2. Power look a like reset(POWER_RESET)\n"
OPTION=$(>&2 echo -en "$PRINT_INPUT Select your preferred option: "; read val; echo $val)

##Check if the OPTION is a number in range from 1 to 2
if [[ ${OPTION} =~ ^[1-2]+$ ]]; then echo -ne ""\\r
else echo -e "$PRINT_ERROR $BOLD${OPTION}$NO_COLOR is not a number in range from 1 to 2"; exit 1
fi

#Check if it is FSMF then block power reset
if [[ ${OPTION} == "2" ]]; then echo -e "Power reset ${ID}"
  if [[ $ID == FSMF || $ID == FSIH ]]; then
    echo -e "$PRINT_ERROR $BOLD${ID}$NO_COLOR does not support power reset"; exit 1
  fi
fi


##Perform correct reset
case $OPTION in
1) echo -e "$PRINT_OK Perform reset on $BOLD 4G and 5G side$NO_COLOR, build: $BOLD${BUILD}$NO_COLOR, amount: $BOLD${AMOUNT}$NO_COLOR"; sleep 1s; echo "DZIENKI HEY"; deactivate; rm /home/ute/logs/console_reset.txt; robot -L TRACE --variable  NUMBER_OF_LOOPS:${AMOUNT} --variable  4G_SW:${BUILD} --variable 5G_SW:${BUILD} --variable DOWNGRADE:False -b /home/ute/RESET_TEST/debug.log /home/ute/MN/UTE/robotlte/testsuite/WMP/GVe/Wroclaw/SFE/UUF/E2E_TESTS/RESET.robot | tee -ia /home/ute/logs/console_reset.txt;;
2) echo -e "$PRINT_OK Perform POWER reset on $BOLD 4G and 5G side$NO_COLOR, build: $BOLD${BUILD}$NO_COLOR, amount: $BOLD${AMOUNT}$NO_COLOR"; sleep 1s; echo "DZIENKI HEY"; deactivate; rm /home/ute/logs/console_reset.txt; robot -L TRACE --variable  NUMBER_OF_LOOPS:${AMOUNT} --variable  4G_SW:${BUILD} --variable 5G_SW:${BUILD} --variable DOWNGRADE:False --variable POWER_RESET:True -b /home/ute/RESET_TEST/debug.log /home/ute/MN/UTE/robotlte/testsuite/WMP/GVe/Wroclaw/SFE/UUF/E2E_TESTS/RESET.robot | tee -ia /home/ute/logs/console_reset.txt;;
esac

