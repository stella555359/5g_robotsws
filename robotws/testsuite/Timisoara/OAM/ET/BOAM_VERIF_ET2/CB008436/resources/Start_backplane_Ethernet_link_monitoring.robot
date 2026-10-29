*** Settings ***


Documentation
...    Copyright 2021 Nokia. All rights reserved.
...    Author: Ichim Vlad (vlad.ichim@nokia.com)
...    Maintenance and refactoring:
...    References:
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log -d


Library        String
Library        BuiltIn
Library        SSHLibrary
Library       taf.gnb.oam.coam.admin.interface

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
${lnBts_r}=                     /MRBTS-1/RAT-1/RUNTIME_VIEW-*/MRBTS_R-*/LNBTS_R-1
${cell_path}=                   /MRBTS-1/RAT-1/MCTRL-*/BBTOP_M-1/MRBTS_M-1/LNBTS_M-1/CELL_M-*
${cpath}=                       /MRBTS-1/RAT-1/BTS_L-*/LNBTS-1/CPLANE-1
${path_bbmod1_bbu}=             /MRBTS-1/RAT-1/BTS_L-*/EQM_L-1/CABINET_L-1/BBMOD_L-1/BBU_L-1
${path_bbmod_left}=                 /MRBTS-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1
${path_bbmod_right}=                 /MRBTS-1/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1
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







*** Keywords ***

Start_backplane_Ethernet_link_monitoring
     [Tags]
     [Documentation]  Monitoring starts after BBMOD reset

     ADMIN INFOMODEL Check If BTS Is OnAir
     Reset BBMOD
     Wait Until Keyword Succeeds   600    60    ADMIN INFOMODEL Check If BTS Is OnAir
     Check Eth Link monitoring is on

Reset BBMOD
     Run keyword if  ('${BTS_side}'=='1')
    ...           Coamadmin.Reset Unit  ${path_bbmod_left}   reset_type=Warm  timeout=${300}
    ...     ELSE  Coamadmin.Reset Unit  ${path_bbmod_right}   reset_type=Warm  timeout=${300}



Check Eth Link monitoring is on
     Wait Until Keyword Succeeds  600s  15s  Run  cat /tmp/btslog2/SYSLOG_*.LOG | grep "state_event_open succeeded"
     Sleep  3
     ${result}=  Run  cat /tmp/btslog2/SYSLOG_*.LOG | grep "state_event_open succeeded"
     Should contain   ${result}   state_event_open succeeded
     Log to Console     ${result}
     ${count} =     Get Count      ${result}   state_event_open succeeded
     Should be True  ${count}>=3

