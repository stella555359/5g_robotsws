*** Settings ***
Documentation
...    Author: Ioana Raluca Radulescu (raluca.radulescu@nokia.com)
...    Maintainer: Ioana Raluca Radulescu (raluca.radulescu@nokia.com)
...    Group in charge: BOAM_VERIF
...    References: doors
...    Feature Description: CB007582-A
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB007582-A/general7317.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        taf.gnb.oam.coam.admin   WITH NAME   taf_admin
Library        taf.transport.ssh        WITH NAME   taf_ssh
Library        taf.config.scf           WITH NAME   taf_scf

#Resource    ./keywords.robot
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

${reasoningStatus_7101}=           stateInfo.reasoningStatus[?]="GnbCpCellUpdateFailedNSA"
${reasoning_path_7101}=            /MRBTS-1/RAT-1/NRTS-1/NRBTS_L-1/NRCELL_L-1

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
${plmn1}=                        ${CURDIR}/plmn1.json
${plmn2}=                        ${CURDIR}/plmn2.json

*** Keywords ***


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

ASOE_Activation_and_cancellation_of_the_fault_7317_EFaultId_NgSetupStopRetryAl
    Log to Console  Start Test Fault ID 7317
    Wait Until Keyword Succeeds
    ...    600
    ...    60
    ...    ADMIN INFOMODEL Check If BTS Is OnAir
    SYSTEM Check if fault is not in active raw alarm  7317   EFaultId_NgSetupStopRetryAl
    ADMIN Check If Alarm Is Not Active  fault_id=7317
    log to console   Change PLMN

    ADMIN Perform Delta Recommissioning                 delta_file=${plmn1}
    ...                                                 skip_parameter_relation_errors=True
     log to console   Wait Fault ID 7317
    ADMIN Check If Alarm Is Active With Timeout  fault_id=7317  timeout=360   #600    #180
#    Check ReasoningStatus for 7317
    log to console   Change back PLMN MCC & MNC
    ADMIN Perform Delta Recommissioning                 delta_file=${plmn2}
    ...                                                 skip_parameter_relation_errors=True
    Sleep  300
    SYSTEM Check if fault is not in active raw alarm  7317   EFaultId_NgSetupStopRetryAl
    ADMIN Check If Alarm Is Not Active  fault_id=7317
#    Check ReasoningStatus Empty for 7317

Blocking cell
    taf.gnb.oam.coam.admin.Block    dist_name=${RNCELL_path}

Unblocking cell
	taf.gnb.oam.coam.admin.Unblock  dist_name=${RNCELL_path}


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


Reset and on Configured
    admin.ADMIN Reset Site
    Wait Until Keyword Succeeds
    ...    900
    ...    10
    ...    ADMIN INFOMODEL Check If BTS Is Configured
