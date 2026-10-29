*** Settings ***
Documentation
...    Author: Madalin Budulan (madalin.budulan@nokia.com)
...    Maintainer: Anca Secea (anca.secea@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC001525-SA-TA
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/5GC001525-SA-TA/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
#Library        ta_wmp_alarm_checker
Library     taf.sbts.oam.coam.admin
Library     taf.transport.ssh

Resource    ../resources/keyword.robot
Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/selenium.robot
#Resource    ../../resources/pdu.robot
Resource    ../../resources/fault_trigger.robot
#Resource    ../../FGCR-9836-K/resources/FGCR-9836-K.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${reasoning_path_left}=             /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1
${reasoning_path_right}=            /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/RMOD_L-1/RU_L-1
${Delta_tmpParam8}=                 ${CURDIR}/tmpParam8_set.json




*** Keywords ***
Fault_generation_1937
    log to console  Start test fault 1937

    Check not uncommissioned state for BTS
    SYSTEM Check if fault is not in active raw alarm  1937  EFaultId_FrDangerouslyOverheat
    Check ReasoningStatus Value is Empty for 1936_1937_1940 fault
    ADMIN Check If Alarm Is Not Active  fault_id=1937

    Generate fault 1937 on RMOD
    Sleep  10
    Check ReasoningStatus Value for 1937 fault
    SYSTEM Check if fault is in active raw alarm  1937  EFaultId_FrDangerouslyOverheat
    ADMIN Check If Alarm Is Active  fault_id=1937
    Check not uncommissioned state for BTS

    Disable fault 1937 on RMOD
    Sleep  10
    ADMIN Check If Alarm Is Not Active  fault_id=1937
    ADMIN Check If Alarm Is In Historical Alarms  fault_id=1937
    Check ReasoningStatus Value is Empty for 1936_1937_1940 fault

Fault_generation_1936
    log to console  Start test fault 1936
    Check not uncommissioned state for BTS
    ADMIN Perform Delta Recommissioning                 delta_file=${Delta_tmpParam8}
    ...                                                 skip_parameter_relation_errors=True
    Sleep  10
    SYSTEM Check if fault is not in active raw alarm  1936  EFaultId_FrTempHigh
    Check ReasoningStatus Value is Empty for 1936_1937_1940 fault
    ADMIN Check If Alarm Is Not Active  fault_id=1936
    Generate fault 1936 on RMOD
    Sleep  10
    Check ReasoningStatus Value for 1936 fault
    SYSTEM Check if fault is in active raw alarm  1936  EFaultId_FrTempHigh
    ADMIN Check If Alarm Is Active   fault_id=1936
#    Verify SW Version
    Check not uncommissioned state for BTS
    Disable fault 1936 on RMOD
    Sleep  10
    SYSTEM Check if fault is not in active raw alarm  1936  EFaultId_FrTempHigh
    SYSTEM Check if fault is in inactive raw alarm  1936  EFaultId_FrTempHigh
    Check ReasoningStatus Value is Empty for 1936_1937_1940 fault
    SYSTEM Check if fault is not in active raw alarm  1940   EFaultId_FrTemperatureValueMissing
    Check ReasoningStatus Value is Empty for 1936_1937_1940 fault

    log to console  Start test fault 1940
    ADMIN Check If Alarm Is Not Active  fault_id=1940
    Generate fault 1940 on RMOD
    Sleep  10
    Check ReasoningStatus Value for 1940 fault
    SYSTEM Check if fault is in active raw alarm  1940  EFaultId_FrTemperatureValueMissing
    ADMIN Check If Alarm Is Not Active  fault_id=1940
    Check not uncommissioned state for BTS
    Disable fault 1940 on RMOD
    Sleep  10
    SYSTEM Check if fault is not in active raw alarm  1940  EFaultId_FrTemperatureValueMissing
    SYSTEM Check if fault is in inactive raw alarm    1940  EFaultId_FrTemperatureValueMissing
    Check ReasoningStatus Value is Empty for 1936_1937_1940 fault

Fault_generation_1940
    log to console  Start test fault 1940

    Check not uncommissioned state for BTS
    SYSTEM Check if fault is not in active raw alarm  1940   EFaultId_FrTemperatureValueMissing
    Check ReasoningStatus Value is Empty for 1936_1937_1940 fault
    ADMIN Check If Alarm Is Not Active  fault_id=1940

    Generate fault 1940 on RMOD
    Sleep  10
    Check ReasoningStatus Value for 1940 fault
    SYSTEM Check if fault is in active raw alarm  1940  EFaultId_FrTemperatureValueMissing
    ADMIN Check If Alarm Is Not Active  fault_id=1940
    Check not uncommissioned state for BTS

    Disable fault 1940 on RMOD
    Sleep  10
    SYSTEM Check if fault is not in active raw alarm  1940  EFaultId_FrTemperatureValueMissing
    SYSTEM Check if fault is in inactive raw alarm    1940  EFaultId_FrTemperatureValueMissing
    Check ReasoningStatus Value is Empty for 1936_1937_1940 fault


Fault_generation_10
    log to console  Start test fault 10
#    SYSTEM Wait For Radio Module Is Online  100
#    ${result}=  run keyword and return status   Admin Check Radio Module Online Status
#    Run Keyword If   ${result}==False  admin.ADMIN Reset Site
    Check not uncommissioned state for BTS
    SYSTEM Check if fault is not in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    ADMIN Check If Alarm Is Not Active  fault_id=10

    SYSTEM Execute Command On IPHY  ddal -s ddal_reboot_graceful
    SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
    Sleep  60
    SYSTEM Check if fault is in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    ADMIN Check If Alarm Is Active  fault_id=10
    Sleep  180
    admin.ADMIN Reset Site
    SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1
    Sleep  500
    SYSTEM Check if fault is not in active raw alarm  0010   EFaultId_NoConnectionToUnitAl
    ADMIN Check If Alarm Is Not Active  fault_id=10

Fault_generation_4383
    log to console  Start test fault 4383

    Check not uncommissioned state for BTS
    SYSTEM Check if fault is not in active raw alarm  4383   EFaultId_VirtualNodeNotRespondingAl
    ADMIN Check If Alarm Is Not Active  fault_id=4383

#    Kill pmagent to trigger fault 4383
    Stop container to trigger fault 4383
#    SYSTEM Check if fault is in active raw alarm  4383  EFaultId_VirtualNodeNotRespondingAl
    ADMIN Check If Alarm Is Active With Timeout  fault_id=4383  timeout=30

    Wait Until Keyword Succeeds  30  1  ADMIN INFOMODEL Check Parameter Value
    ...    dist_name=/MRBTS-1/RAT-1/FRI-${BTS_Side}/RECOVERY_RESET_IND-1
    ...    dict_param=recoveryFaultID
    ...    value=4383
#Add check for Site recovery

    SYSTEM Wait Till Gnb Will Not Be Pingable For A Given Period
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
    Sleep  180
    SYSTEM Check if fault is not in active raw alarm  4383   EFaultId_VirtualNodeNotRespondingAl
    ADMIN Check If Alarm Is Not Active  fault_id=4383

Fault_generation_23
    log to console  Start test fault 23

    Check not uncommissioned state for BTS
    SYSTEM Check if fault is not in active raw alarm  0023   EFaultId_IncompatibleSwVersionAl
    ADMIN Check If Alarm Is Not Active  fault_id=23

    SYSTEM Execute Command On IPHY  sed -i '/bldVersion/s/5G/4G/' /ffs/run/simmode/iphy.xml
    SYSTEM Execute Command On IPHY  ddal -s ddal_reboot_graceful
#    admin.ADMIN Reset Site
    SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
    SYSTEM Wait Till Iphy Will Be Pingable For A Given Period
    Sleep  500
    SYSTEM Check if fault is in active raw alarm  0023   EFaultId_IncompatibleSwVersionAl
    ADMIN Check If Alarm Is Active  fault_id=23

    SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1
    SYSTEM Execute Command On IPHY  sed -i '/bldVersion/s/4G/5G/' /ffs/run/simmode/iphy.xml
    SYSTEM Execute Command On IPHY  ddal -s ddal_reboot_graceful  alias=iphy_recover
#    admin.ADMIN Reset Site
    SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
    SYSTEM Wait Till Iphy Will Be Pingable For A Given Period
    Sleep  500
    SYSTEM Check if fault is not in active raw alarm  0023   EFaultId_IncompatibleSwVersionAl
    ADMIN Check If Alarm Is Not Active  fault_id=23

Fault_generation_1850
    log to console  Start test fault 1850
#   save iphy.xml before modifying and use it for recover purpose
#   create iphy.xml in resources that will trigger the fault

    SYSTEM Execute Command On IPHY  cp /ffs/run/simmode/iphy.xml /ffs/run/simmode/iphy.xml.backup
    Check not uncommissioned state for BTS
    SYSTEM Check if fault is not in active raw alarm  1850  EFaultId_SwCorruptedAl
    ADMIN Check If Alarm Is Not Active  fault_id=1850

    SYSTEM Execute Command On IPHY  sed -ri '/bldVersion/s/>.*</>?</' /ffs/run/simmode/iphy.xml
    SYSTEM Execute Command On IPHY  sed -ri '/buildversion/s/>.*</>?</' /ffs/run/simmode/iphy.xml
    SYSTEM Execute Command On IPHY  ddal -s ddal_reboot_graceful

    SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
    SYSTEM Wait Till Iphy Will Be Pingable For A Given Period
    Sleep  500

    SYSTEM Check if fault is in active raw alarm  1850   EFaultId_SwCorruptedAl
    ADMIN Check If Alarm Is Active  fault_id=1850

    SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1
    SYSTEM Execute Command On IPHY  cp /ffs/run/simmode/iphy.xml.backup /ffs/run/simmode/iphy.xml
    SYSTEM Execute Command On IPHY  ddal -s ddal_reboot_graceful  alias=iphy_recover

    SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
    SYSTEM Wait Till Iphy Will Be Pingable For A Given Period
    Sleep  500
    SYSTEM Check if fault is not in active raw alarm  1850   EFaultId_SwCorruptedAl
    ADMIN Check If Alarm Is Not Active  fault_id=1850

Fault_generation_28
    log to console  Start test fault 28

    Check not uncommissioned state for BTS
    SYSTEM Check if fault is not in active raw alarm  0028   EFaultId_SwPackageAl
    ADMIN Check If Alarm Is Not Active  fault_id=28
    fault_trigger.Test Preconditions Fault 28
    fault_trigger.Trigger Fault 28
    Sleep  60
    SYSTEM Check if fault is in active raw alarm  0028   EFaultId_SwPackageAl
    ADMIN Check If Alarm Is Active  fault_id=28
    admin.ADMIN Reset Site
#    SYSTEM Wait Till Gnb Will Not Be Pingable For A Given Period
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
    SYSTEM Wait Till Iphy Will Be Pingable For A Given Period
    Sleep  500
    Check not uncommissioned state for BTS
    SYSTEM Check if fault is not in active raw alarm  0028   EFaultId_SwPackageAl
    ADMIN Check If Alarm Is Not Active  fault_id=28

Fault_generation_29
    log to console  Start test fault 29
    Check not uncommissioned state for BTS
    SYSTEM Check if fault is not in active raw alarm  0029   EFaultId_FileCorruptionAl
    ADMIN Check If Alarm Is Not Active  fault_id=29
    Fault 29 Trigger
    SYSTEM Check if fault is in active raw alarm  0029   EFaultId_FileCorruptionAl
    ADMIN Check If Alarm Is Active  fault_id=29
    admin.ADMIN Reset Site
#    SSH SMOD Reboot
    Sleep  360
    SYSTEM Check if fault is not in active raw alarm  0029   EFaultId_FileCorruptionAl
    ADMIN Check If Alarm Is Not Active  fault_id=29
    log  Clear Fault 29
    ADMIN Update Software With Activation
    ...            sw_package=${SW_DESTINATION}/${main_package}
    ...            timeout=2000
    Sleep  300
    ADMIN Check If Alarm Is Not Active  fault_id=23
    admin.ADMIN Reset Site
    Sleep  360
    Check not uncommissioned state for BTS

Fault_generation_30
    log to console  Start test fault 30
    Check not uncommissioned state for BTS
    SYSTEM Check if fault is not in active raw alarm  0030   EFaultId_SwUpdateAl
    ADMIN Check If Alarm Is Not Active  fault_id=30
    Fault 30 Trigger
    log to console  Checking for fault 30
    ADMIN Wait Until Fault Should Be Raised    fault_id=30
    SYSTEM Check if fault is in active raw alarm  0030   EFaultId_SwUpdateAl
    ADMIN Check If Alarm Is Active  fault_id=30
    log to console  Reset Site
    admin.ADMIN Reset Site
    Sleep  360
    SYSTEM Check if fault is not in active raw alarm  0030   EFaultId_SwUpdateAl
    ADMIN Check If Alarm Is Not Active  fault_id=30
    Check not uncommissioned state for BTS


Kill pmagent to trigger fault 4383
    ${process_pid}=   SYSTEM Execute Command On gNB
    ...    command=ps aux | grep -i "pmagent" | egrep -v "grep|bash" | awk '{print $2}'
    @{list_process_pid}=  split to lines  ${process_pid}
    SYSTEM Execute Command On gNB
    ...    command=kill -11 @{list_process_pid}[0]

Stop container to trigger fault 4383
    SYSTEM Execute Command On gNB
    ...    command=systemctl stop hwr-container@TRACECM00.service

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

Check ReasoningStatus Value is Empty for 1936_1937_1940 fault
    Run Keyword If     '${OUT_ADMIN_SMOD_POSITION}' == 'left'
    ...       ADMIN INFOMODEL Check ReasoningStatus Value is Empty
    ...         dist_name=${reasoning_path_left}
    Run Keyword If     '${OUT_ADMIN_SMOD_POSITION}' == 'right'
     ...       ADMIN INFOMODEL Check ReasoningStatus Value is Empty
    ...         dist_name=${reasoning_path_right}

Check ReasoningStatus Value for 1936 fault
    Run Keyword If     '${OUT_ADMIN_SMOD_POSITION}' == 'left'
    ...       ADMIN INFOMODEL Check ReasoningStatus Value
    ...         dist_name=${reasoning_path_left}
    ...    value=HighTemperature
    Run Keyword If     '${OUT_ADMIN_SMOD_POSITION}' == 'right'
    ...         ADMIN INFOMODEL Check ReasoningStatus Value
    ...         dist_name=${reasoning_path_right}
    ...         value=HighTemperature

Check ReasoningStatus Value for 1937 fault
    Run Keyword If     '${OUT_ADMIN_SMOD_POSITION}' == 'left'
    ...       ADMIN INFOMODEL Check ReasoningStatus Value
    ...         dist_name=${reasoning_path_left}
    ...         value=DangerouslyOverheated
    Run Keyword If     '${OUT_ADMIN_SMOD_POSITION}' == 'right'
     ...       ADMIN INFOMODEL Check ReasoningStatus Value
    ...         dist_name=${reasoning_path_right}
    ...         value=DangerouslyOverheated

Check ReasoningStatus Value for 1940 fault
    Run Keyword If     '${OUT_ADMIN_SMOD_POSITION}' == 'left'
    ...         ADMIN INFOMODEL Check ReasoningStatus Value
    ...         dist_name=${reasoning_path_left}
    ...         value=TemperatureValueMissing
    Run Keyword If     '${OUT_ADMIN_SMOD_POSITION}' == 'right'
    ...         ADMIN INFOMODEL Check ReasoningStatus Value
    ...         dist_name=${reasoning_path_right}
    ...         value=TemperatureValueMissing


