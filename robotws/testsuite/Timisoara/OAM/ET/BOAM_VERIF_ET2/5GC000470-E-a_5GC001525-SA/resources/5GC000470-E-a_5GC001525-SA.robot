*** Settings ***
Documentation
...    Author: Madalin Budulan (madalin.budulan@nokia.com)
...    Maintainer: Sergiu Alecu (sergiu.alecu@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC000470-E-a_5GC001525-SA
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC000470-E-a_5GC001525-SA/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
#Library        ta_wmp_alarm_checker

Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/selenium.robot
#Resource    ../../resources/pdu.robot
Resource    ../../resources/fault_trigger.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${reasoning_path}=            /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1

*** Keywords ***

5GC000470-E-a_5GC001525-SA_Fault_generation_10
    log to console  Start test fault 10

    Check If BTS on Right side Is Not In Uncommissioned State
    SYSTEM Check if fault is not in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    ADMIN Check If Alarm Is Not Active  fault_id=10

#    SYSTEM Execute Command On IPHY  ddal -s ddal_reboot_graceful
    SYSTEM Execute Command On IPHY  reboot --reboot
    SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
#    Sleep  60
    Wait Until Keyword Succeeds  300  30    SYSTEM Check if fault is in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    ADMIN Check If Alarm Is Active  fault_id=10

    SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1
#    Sleep  900
    Wait Until Keyword Succeeds  900  30    SYSTEM Check if fault is not in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    ADMIN Check If Alarm Is Not Active  fault_id=10


5GC000470-E-a_5GC001525-SA_Fault_generation_23
    log to console  Start test fault 23

    Check If BTS on Right side Is Not In Uncommissioned State
    SYSTEM Check if fault is not in active raw alarm  0023   EFaultId_IncompatibleSwVersionAl
    ADMIN Check If Alarm Is Not Active  fault_id=23

    SYSTEM Execute Command On IPHY  sed -i '/bldVersion/s/5G/4G/' /ffs/run/simmode/iphy.xml
#    SYSTEM Execute Command On IPHY  ddal -s ddal_reboot_graceful
    SYSTEM Execute Command On IPHY  reboot --reboot
    SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
    SYSTEM Wait Till Iphy Will Be Pingable For A Given Period
#    Sleep  500
    Wait Until Keyword Succeeds  600  30    SYSTEM Check if fault is in active raw alarm  0023   EFaultId_IncompatibleSwVersionAl
    ADMIN Check If Alarm Is Active  fault_id=23

    SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1
    SYSTEM Execute Command On IPHY  sed -i '/bldVersion/s/4G/5G/' /ffs/run/simmode/iphy.xml
#    SYSTEM Execute Command On IPHY  ddal -s ddal_reboot_graceful  alias=iphy_recover
    SYSTEM Execute Command On IPHY  reboot --reboot   alias=iphy_recover
    SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
    SYSTEM Wait Till Iphy Will Be Pingable For A Given Period
#    Sleep  500
    Wait Until Keyword Succeeds  600  30    SYSTEM Check if fault is not in active raw alarm  0023   EFaultId_IncompatibleSwVersionAl
    ADMIN Check If Alarm Is Not Active  fault_id=23



Kill pmagent to trigger fault 4383
    ${process_pid}=   SYSTEM Execute Command On gNB
    ...    command=ps aux | grep -i "pmagent" | egrep -v "grep|bash" | awk '{print $2}'
    @{list_process_pid}=  split to lines  ${process_pid}
    SYSTEM Execute Command On gNB
    ...    command=kill -11 @{list_process_pid}[0]

Generate fault ${fault_id} on RMOD
    Telnet.Open Connection  192.168.200.1  port=8023  prompt=>  newline=LF
    Telnet.Execute Command  trigger_rf_fault 0 ${fault_id} module MAJ
    Sleep	5s
    Telnet.Close All Connections

Disable fault ${fault_id} on RMOD
    Telnet.Open Connection  192.168.200.1  port=8023  prompt=>  newline=LF
    Telnet.Execute Command  cancel_rf_fault 0 ${fault_id} module
    Sleep	5s
    Telnet.Close All Connections

#    collect raw alarm history file  /tmp/alarms.txt

