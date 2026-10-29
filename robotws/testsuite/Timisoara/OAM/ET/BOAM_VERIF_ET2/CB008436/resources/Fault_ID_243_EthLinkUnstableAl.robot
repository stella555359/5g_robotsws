*** Settings ***
Documentation
...    Copyright 2021 Nokia. All rights reserved.
...    Author: Ichim Vlad (vlad.ichim@nokia.com)
...    Maintenance and refactoring: Alexandra Istrate (alexandra.istrate@nokia.com)
...    References:
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d


Library        String
Library        BuiltIn
Library        SSHLibrary
Library       taf.sbts.oam.coam.admin.interface

#Resource       ../resources/general.robot
Resource       ../../resources/faults.robot
Resource       ../../resources/pretest_posttest.robot
Resource       ../../resources/admin.robot
Resource       ../../resources/admin_infomodel.robot
Resource    ../../resources/AirPhone/resources/ute/ute_wts_runner.robot




*** Variables ***

${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True
${fault_id}=                    243
${alarm_id}=                    7101
${EFaultId}=                    EFaultId_EthLinkUnstableAl
${lnBts_r}=                     /MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-1
${cell_path}=                   /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1/CELL_M-*
${cpath}=                       /MRBTS-1/RAT-1/BTS_L-*/LNBTS-1/CPLANE-1
${path_bbmod1_bbu}=             /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/CABINET_L-1/BBMOD_L-1/BBU_L-1
${path_bbmod1}=                 /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/CABINET_L-1/BBMOD_L-1

${smod_bbu_L_path}=             /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/CABINET_L-1/BBMOD_L-*/BBU_L-1
${smod_path}=                   /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/CABINET_L-1/SMOD_L-*

${usageState}=                  stateInfo.usageState=regex"Idle|Active"
${proceduralState}=             stateInfo.proceduralState=regex"hwConfigured|trsDataConfigured"
${operationalState}=            stateInfo.operationalState="Enabled"
${operationalState_dis}=        stateInfo.operationalState="Disabled"
${availabilityStatus}=          stateInfo.availabilityStatus="Online"
${availabilityStatus_degr}=     stateInfo.availabilityStatus="Degraded"
${availabilityStatus_off}=      stateInfo.availabilityStatus="Offline"
${proceduralState_onAir}=       stateInfo.proceduralState="OnAirDone"
${proceduralState_reset}=       stateInfo.proceduralState="Resetting"
${reasoningStatus}=             stateInfo.reasoningStatus[?]="EthLinkUnstable"
${reasoningStatus_empty}=       stateInfo.reasoningStatus=empty

${fault_severity_warning}=      faultSeverity="Warning"
${alarm_severity_warning}=      Warning

${alarm_name_7101}=             alarmName="BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION"
${alarm_number_7101}=           alarmNumber=7101
${alarm_detail}=                alarmText.alarmDetail="Baseband card autonomous reset as recovery action"

${alarm_detail_NBR_52}=         alarmText.alarmDetailNbr=52
${alarm_detail_NBR_SM_52}=      AlarmInformation.AlarmText._alarmDetailNbr:52
${additionalFaultID_SM_52}=     AlarmInformation.AlarmText._alarmAdditionalInfo.additionalFaultID:52

${reset_req_path}=              /MRBTS-1/RAT-1/DEM-*/ENTITY_RESET_REQ-*
${recovery_reset_ind_path}=     /MRBTS-1/RAT-1/FRI-*/RECOVERY_RESET_IND-*

${alarm_path}=                  /MRBTS-1/RAT-1/FRI-*/ALARM-*
${alarm_path_cell}=             /MRBTS-1/RAT-1/LTS-*/LNBTS_L-1/LNCEL_L-*/ALARM_L-*

${timeout}=                     90
${alias}=                       admin_1


&{FAULT_243}                    fault_id=243
...                             alarm_id=7101
...                             alarm_severity=Warning
...                             notifier=MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1
...                             fault_name="Baseband card autonomous reset as recovery action"

@{FAULT_ALLOWED_LIST_TEST_243}=  &{FAULT_243}  @{FAULT_ALLOWED_LIST_COR}




*** Keywords ***



Generate FaultID 243
    Run keyword if  ('${BTS_side}'=='1')
    ...           CoamAdmin.Send Hwapi Api2 Alarm Msg    ${0x123D04B5}   ${0x10111202}    ${1}   ${243}    ${0x123D}
    ...   ELSE    CoamAdmin.Send Hwapi Api2 Alarm Msg    ${0x223D04B5}   ${0x20111202}    ${1}   ${243}    ${0x223D}


Check Eth Link monitoring is off
     Wait Until Keyword Succeeds  600s  5s  Run  cat /tmp/btslog2/SYSLOG_*.LOG | grep "state_event_close succeeded"
     ${result}=  Run  cat /tmp/btslog2/SYSLOG_*.LOG | grep "state_event_close succeeded"
     Should contain   ${result}   state_event_close succeeded
     Log to Console     ${result}
     ${count} =     Get Count      ${result}   state_event_close succeeded
     Should be True  ${count}==3

