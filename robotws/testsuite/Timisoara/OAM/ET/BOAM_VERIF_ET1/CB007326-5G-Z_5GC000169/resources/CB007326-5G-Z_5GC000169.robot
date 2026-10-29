*** Settings ***
Documentation
...    Author: Ana-Maria Rodean (ana-maria.rodean@nokia.com)
...    Maintainer: Ana-Maria Rodean (ana-maria.rodean@nokia.com)
...    Group in charge: BOAM_VERIF
...    References: doors
...    Feature Description: CB005752-5G-A_5GC000169
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007326-5G-Z_5GC000169/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        taf.gnb.oam.coam.admin   WITH NAME   taf_admin
Library        taf.transport.ssh        WITH NAME   taf_ssh
Library        taf.config.scf           WITH NAME   taf_scf

Resource    ./keywords.robot
Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/fault_trigger.robot
Resource    ../../resources/AirPhone/resources/ute/ute_wts_runner.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${reasoningStatus_7100}=           stateInfo.reasoningStatus[?]="GnbCellActivationFailedX2Degraded"
${reasoning_path_7100}=            /MRBTS-1/RAT-1/NRTS-1/NRBTS_L-1/NRCELL_L-1

${reasoningStatus_7101}=           stateInfo.reasoningStatus[?]="GnbCpCellUpdateFailedNSA"
${reasoning_path_7101}=            /MRBTS-1/RAT-1/NRTS-1/NRBTS_L-1/NRCELL_L-1

${reasoningStatus_7506}=           stateInfo.reasoningStatus[?]="GnbCpRtCellUpdateFailed"
${reasoning_path_7506}=            /MRBTS-1/RAT-1/NRTS-1/NRBTS_L-1/NRCELL_L-1

${RNCELL_path}=		               /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
${RMOD_path}=                      /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1

${X2LinkLock}=                        ${CURDIR}/X2LinkLock_locked.json
${X2LinkUnlock}=                      ${CURDIR}/X2LinkLock_unlocked.json
${nsaCellActivationAlarmTimer_240}=   ${CURDIR}/nsaCellActivationAlarmTimer_240.json
${nsaCellActivationAlarmTimer_600}=   ${CURDIR}/nsaCellActivationAlarmTimer_600.json
${fPdcchMonOccsnPo_378}=              ${CURDIR}/fPdcchMonOccsnPo_378.json
${fPdcchMonOccsnPo_154}=              ${CURDIR}/fPdcchMonOccsnPo_154.json
${prachConfigurationIndex_0}=         ${CURDIR}/prachConfigurationIndex_0.json
${prachConfigurationIndex_93}=        ${CURDIR}/prachConfigurationIndex_93.json

*** Keywords ***
ASOE_Activation_and_cancellation_of_the_fault_7100_EFaultId_GnbCellActivationFailedX2Al
    Log to Console  Start Test Fault ID 7100
    Wait Until Keyword Succeeds
    ...    600
    ...    60
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    SYSTEM Check if fault is not in active raw alarm  7100   EFaultId_GnbCellActivationFailedX2Al
    ADMIN Check If Alarm Is Not Active  fault_id=7100
#    ADMIN Check If Alarm Is Not Active  fault_id=7300
    Log to Console   Change the value for X2Link (lock)
    ADMIN Perform Delta Recommissioning                 delta_file=${X2LinkLock}
    ...                                                 skip_parameter_relation_errors=True
# Different behavior on local TL; Shoud be observed on UTE Cloud
    Log to Console   Wait Fault ID 7300
    ADMIN Check If Alarm Is Active With Timeout  fault_id=7300  timeout=180
    Log to Console  Restart IPHY
#    SYSTEM Execute Command On IPHY  ddal -s ddal_reboot_graceful
    SYSTEM Execute Command On IPHY  reboot --reboot
    SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
    SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1
#    taf_admin.Reset Unit        dist_name=${RMOD_path}  timeout=180
    Log to Console   Wait Fault ID 7100
    ADMIN Check If Alarm Is Active With Timeout  fault_id=7100  timeout=1800
    Check ReasoningStatus for 7100
    Log to Console   Change the back value for X2Link (unlock)
    ADMIN Perform Delta Recommissioning                 delta_file=${X2LinkUnlock}
    ...                                                 skip_parameter_relation_errors=True
    Sleep  10s
    Log to Console   BTS reset
    Reset and on configured
    SYSTEM Check if fault is not in active raw alarm  7100   EFaultId_GnbCellActivationFailedX2Al
    ADMIN Check If Alarm Is Not Active  fault_id=7100
    Check ReasoningStatus Empty for 7100



ASOE_Activation_and_cancellation_of_the_fault_7101_EFaultId_GnbCpCellUpdateFailedAl
    Log to Console  Start Test Fault ID 7101
    Wait Until Keyword Succeeds
    ...    600
    ...    60
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    SYSTEM Check if fault is not in active raw alarm  7101   EFaultId_GnbCpCellUpdateFailedAl
    ADMIN Check If Alarm Is Not Active  fault_id=7101
    log to console   Change the value for nsaCellActivationAlarmTimer (240)
#    ADMIN Perform Delta Recommissioning                 delta_file=${fPdcchMonOccsnPo_378}
#    ...                                                 skip_parameter_relation_errors=True
    ADMIN Perform Delta Recommissioning                 delta_file=${nsaCellActivationAlarmTimer_240}
    ...                                                 skip_parameter_relation_errors=True
    log to console   Blocking cell
    Blocking cell
    ADMIN Check If Alarm Is Active With Timeout  fault_id=49  timeout=180
    SYSTEM Execute Command On gNB
    ...    command=iptables -I INPUT 1 -s 10.0.1.121 -p sctp --chunk-types any DATA -j REJECT
    sleep   10
    log to console   Unblocking cell
    Unblocking cell
    log to console   Wait Fault ID 7101
    ADMIN Check If Alarm Is Active With Timeout  fault_id=7101  timeout=360   #600    #180
    Check ReasoningStatus for 7101
    log to console   Change back the value for nsaCellActivationAlarmTimer (600)
    ADMIN Perform Delta Recommissioning                 delta_file=${nsaCellActivationAlarmTimer_600}
    ...                                                 skip_parameter_relation_errors=True
#    ADMIN Perform Delta Recommissioning                 delta_file=${fPdcchMonOccsnPo_154}
#    ...                                                 skip_parameter_relation_errors=True
    log to console    BTS reset
    Reset and on Configured
    SYSTEM Check if fault is not in active raw alarm  7101   EFaultId_GnbCpCellUpdateFailedAl
    ADMIN Check If Alarm Is Not Active  fault_id=7101
    Check ReasoningStatus Empty for 7101


ASOE_Activation_and_Cancellation_of_the_Fault_7506_EFaultId_GnbCpRtCellUpdateFailedAl
    Wait Until Keyword Succeeds
    ...    600
    ...    60
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    Log to Console  Start Test Fault ID 7506
    SYSTEM Check if fault is not in active raw alarm  7506   EFaultId_GnbCpRtCellUpdateFailedAl
    ADMIN Check If Alarm Is Not Active  fault_id=7506

    ADMIN Perform Delta Recommissioning                 delta_file=${prachConfigurationIndex_0}
    ...                                                 skip_parameter_relation_errors=True
    Wait Until Keyword Succeeds
    ...    600
    ...    30
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    ADMIN Check If Alarm Is Active With Timeout  fault_id=7506  timeout=300
    Check ReasoningStatus for 7506
    ADMIN Perform Delta Recommissioning                 delta_file=${prachConfigurationIndex_93}
    ...                                                 skip_parameter_relation_errors=True
    Wait Until Keyword Succeeds
    ...    600
    ...    60
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    Log to console    BTS reset
    Reset and on Configured
    Sleep  100
    SYSTEM Check if fault is not in active raw alarm  7506   EFaultId_GnbCpRtCellUpdateFailedAl
    ADMIN Check If Alarm Is Not Active  fault_id=7506
    Check ReasoningStatus Empty for 7506
    ...    dist_name=${reasoning_path_7506}
    ...    value=GnbCpRtCellUpdateFailed


#    :FOR    ${INDEX}  IN RANGE    1   ${count}
#    \   Log to Console  Activating and Deactivating Fault ID 7506 for the ${INDEX} time
#    \   Activation_and_Cancellation_of_the_Fault_7506_EFaultId_GnbCpRtCellUpdateFailedAl

#    Wait Until Keyword Succeeds
#    ...    600
#    ...    60
#    ...    ADMIN INFOMODEL Check If BTS Is OnAir


#-----------------------------------------------------------------------------------------------------------------
Activation_and_Cancellation_of_the_Fault_7506_EFaultId_GnbCpRtCellUpdateFailedAl
    Wait Until Keyword Succeeds
    ...    600
    ...    60
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    SYSTEM Check if fault is not in active raw alarm  7506   EFaultId_GnbCpRtCellUpdateFailedAl
    ADMIN Check If Alarm Is Not Active  fault_id=7506
    ADMIN Perform Delta Recommissioning                 delta_file=${ssbScs_30KHz}
    ...                                                 skip_parameter_relation_errors=True
    Wait Until Keyword Succeeds
    ...    600
    ...    30
    ...    ADMIN INFOMODEL Check If BTS Is Configured
    ADMIN Check If Alarm Is Active With Timeout  fault_id=7506  timeout=300
    Check ReasoningStatus for 7506
    ADMIN Perform Delta Recommissioning                 delta_file=${ssbScs_15KHz}
    ...                                                 skip_parameter_relation_errors=True
    Wait Until Keyword Succeeds
    ...    600
    ...    60
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    SYSTEM Check if fault is not in active raw alarm  7506   EFaultId_GnbCpRtCellUpdateFailedAl
    ADMIN Check If Alarm Is Not Active  fault_id=7506
    Check ReasoningStatus Empty for 7506
    ...    dist_name=${reasoning_path_7506}
    ...    value=GnbCpRtCellUpdateFailed

#Add Flags In Swconfig File
#    ${status}    SYSTEM Execute Command On gNB
#    ...    command=cat /rom/swconfig.txt | grep 0x590000
#    ${status}    Run Keyword And Return Status    Should Be Empty    ${status}
#    Run Keyword If    ${status}
#    ...    Run Keywords
#    ...    SYSTEM Execute Command On gNB
#    ...    command=echo 0x590000=9 >> /rom/swconfig.txt    AND
#    ...    SYSTEM Execute Command On gNB
#    ...    command=crasign /rom/swconfig.txt
#
#    ${status}    SYSTEM Execute Command On gNB
#    ...    command=cat /rom/swconfig.txt | grep 0x5800BA
#    ${status}    Run Keyword And Return Status    Should Be Empty    ${status}
#    Run Keyword If    ${status}
#    ...    Run Keywords
#    ...    SYSTEM Execute Command On gNB
#    ...    command=echo 0x5800BA=12 >> /rom/swconfig.txt    AND
#    ...    SYSTEM Execute Command On gNB
#    ...    command=crasign /rom/swconfig.txt
#
#    SYSTEM Execute Command On gNB
#    ...    command=reboot
#    Wait Until Keyword Succeeds
#    ...    240
#    ...    5
#    ...    SYSTEM Check If Host Is Not Pingable
#    ...    host_ip_address=192.168.255.1
#    Wait Until Keyword Succeeds
#    ...    240
#    ...    5
#    ...    SYSTEM Check If Host Is Pingable
#    ...    host_ip_address=192.168.255.1
#
#Comment Flags In Swconfig File
#    SYSTEM Execute Command On gNB
#    ...    command=sed -i 's/0x590000=9/#0x590000=9/' /rom/swconfig.txt
#    SYSTEM Execute Command On gNB
#    ...    command=sed -i 's/0x5800BA=12/#0x5800BA=12/' /rom/swconfig.txt
#    SYSTEM Execute Command On gNB
#    ...    command=crasign /rom/swconfig.txt

#    SYSTEM Execute Command On gNB
#    ...    command=reboot
#    Wait Until Keyword Succeeds
#    ...    240
#    ...    5
#    ...    SYSTEM Check If Host Is Not Pingable
#    ...    host_ip_address=192.168.255.1
#    Wait Until Keyword Succeeds
#    ...    240
#    ...    5
#    ...    SYSTEM Check If Host Is Pingable
#    ...    host_ip_address=192.168.255.1

Blocking cell
    taf.gnb.oam.coam.admin.Block    dist_name=${RNCELL_path}

Unblocking cell
	taf.gnb.oam.coam.admin.Unblock  dist_name=${RNCELL_path}


Check ReasoningStatus Empty for 7100
    ADMIN INFOMODEL Check ReasoningStatus Value is Empty
    ...    dist_name=${reasoning_path_7100}

Check ReasoningStatus for 7100
    Wait Until Keyword Succeeds  300  60  ADMIN INFOMODEL Check ReasoningStatus Value
    ...    dist_name=${reasoning_path_7100}
    ...    value=GnbCellActivationFailedX2Degraded


Check ReasoningStatus Empty for 7101
    ADMIN INFOMODEL Check ReasoningStatus Value is Empty
    ...    dist_name=${reasoning_path_7101}

Check ReasoningStatus for 7101
    Wait Until Keyword Succeeds  300  60  ADMIN INFOMODEL Check ReasoningStatus Value
    ...    dist_name=${reasoning_path_7101}
    ...    value=GnbCpCellUpdateFailedNSA


Check if fault is not in active raw alarm
      [Arguments]    ${fault_id}
    ...              ${EFaultId}
    ${RawAlarms}=   taf.gnb.oam.coam.admin.get raw alarm history file
    ${RawAlamrsActive}=  fetch from left  ${RawAlarms}  Inactive faults
    Should not contain  ${RawAlamrsActive}  (${fault_id})
    Should not contain  ${RawAlamrsActive}  ${EFaultId}


Check ReasoningStatus Empty for 7506
#    ADMIN INFOMODEL Check ReasoningStatus Value is Empty
#    ...    dist_name=${reasoning_path_7506}
    [Arguments]
    ...    ${dist_name}
    ...    ${value}
    ${dict_value}    taf.gnb.oam.coam.admin.get_parameters
    ...    dist_name=${dist_name}
    ...    pattern=
    ${dict_value}    Get From Dictionary
    ...    dictionary=${dict_value}
    ...    key=stateInfo
    ${dict_value}    Get From Dictionary
    ...    dictionary=${dict_value}
    ...    key=reasoningStatus
    list should not contain value  ${dict_value}  ${value}


Check ReasoningStatus for 7506
    Wait Until Keyword Succeeds  300  60  ADMIN INFOMODEL Check ReasoningStatus Value
    ...    dist_name=${reasoning_path_7506}
    ...    value=GnbCpRtCellUpdateFailed



Reset and on Configured
    admin.ADMIN Reset Site
    Wait Until Keyword Succeeds
    ...    900
    ...    10
    ...    ADMIN INFOMODEL Check If BTS Is Configured
