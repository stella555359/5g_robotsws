*** Settings ***
Documentation
...    Author: Alin Necula (alin.necula@nokia.com)
...    Maintainer: Alin Necula (alin.necula@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description: CB005752-5G-A_5GC000169
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/CB005752-5G-A_5GC000169/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        taf.sbts.oam.coam.admin   WITH NAME   taf_admin
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

${reasoning_path_1937_left}=       /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1
${reasoning_path_1937_right}=      /MRBTS-1/RAT-1/BTS_L-4/EQM_L-1/RMOD_L-1/RU_L-1

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
${ssbScs_15KHz}=                      ${CURDIR}/ssbScs_15KHz.json
${ssbScs_30KHz}=                      ${CURDIR}/ssbScs_30KHz.json

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
    ADMIN Perform Delta Recommissioning                 delta_file=${X2LinkLock}
    ...                                                 skip_parameter_relation_errors=True
# Different behavior on local TL; Shoud be observed on UTE Cloud
    Log to Console   Wait Fault ID 7300
    ADMIN Check If Alarm Is Active With Timeout  fault_id=7300  timeout=180
    Log to Console  Restart IPHY
    SYSTEM Execute Command On IPHY  ddal -s ddal_reboot_graceful
    SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
    SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1
#    taf_admin.Reset Unit        dist_name=${RMOD_path}  timeout=180
    Log to Console   Wait Fault ID 7100
    ADMIN Check If Alarm Is Active With Timeout  fault_id=7100  timeout=1800
    Check ReasoningStatus for 7100
    ADMIN Perform Delta Recommissioning                 delta_file=${X2LinkUnlock}
    ...                                                 skip_parameter_relation_errors=True
    Sleep  10s
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
    ADMIN Perform Delta Recommissioning                 delta_file=${fPdcchMonOccsnPo_378}
    ...                                                 skip_parameter_relation_errors=True
    ADMIN Perform Delta Recommissioning                 delta_file=${nsaCellActivationAlarmTimer_240}
    ...                                                 skip_parameter_relation_errors=True
    Blocking cell
    ADMIN Check If Alarm Is Active With Timeout  fault_id=49  timeout=180
    SYSTEM Execute Command On gNB
    ...    command=iptables -I INPUT 1 -s 10.15.236.200 -p sctp --chunk-types any DATA -j REJECT
    ...    alias=${SYSTEM_ALIAS_ASOE}
    sleep   10
    Unblocking cell
    log to console   Wait Fault ID 7101
    ADMIN Check If Alarm Is Active With Timeout  fault_id=7101  timeout=180   #600    #180
    Check ReasoningStatus for 7101
    ADMIN Perform Delta Recommissioning                 delta_file=${nsaCellActivationAlarmTimer_600}
    ...                                                 skip_parameter_relation_errors=True
    ADMIN Perform Delta Recommissioning                 delta_file=${fPdcchMonOccsnPo_154}
    ...                                                 skip_parameter_relation_errors=True
    Reset and on Configured
    SYSTEM Check if fault is not in active raw alarm  7101   EFaultId_GnbCpCellUpdateFailedAl
    ADMIN Check If Alarm Is Not Active  fault_id=7101
    Check ReasoningStatus Empty for 7101


ASOE_Activation_and_Cancellation_of_the_Fault_7506_EFaultId_GnbCpRtCellUpdateFailedAl
    [Arguments]  ${count}=6
    Log to Console  Start Robustness Test Fault ID 7506
    :FOR    ${INDEX}  IN RANGE    1   ${count}
    \   Log to Console  Activating and Deactivating Fault ID 7506 for the ${INDEX} time
    \   Activation_and_Cancellation_of_the_Fault_7506_EFaultId_GnbCpRtCellUpdateFailedAl



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


Blocking cell
    taf.sbts.oam.coam.admin.Block    dist_name=${RNCELL_path}

Unblocking cell
	taf.sbts.oam.coam.admin.Unblock  dist_name=${RNCELL_path}


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
    ${RawAlarms}=   taf.sbts.oam.coam.admin.get raw alarm history file
    ${RawAlamrsActive}=  fetch from left  ${RawAlarms}  Inactive faults
    Should not contain  ${RawAlamrsActive}  (${fault_id})
    Should not contain  ${RawAlamrsActive}  ${EFaultId}


Check ReasoningStatus Empty for 7506
#    ADMIN INFOMODEL Check ReasoningStatus Value is Empty
#    ...    dist_name=${reasoning_path_7506}
    [Arguments]
    ...    ${dist_name}
    ...    ${value}
    ${dict_value}    taf.sbts.oam.coam.admin.get_parameters
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
    ...    30
    ...    ADMIN INFOMODEL Check If BTS Is Configured
