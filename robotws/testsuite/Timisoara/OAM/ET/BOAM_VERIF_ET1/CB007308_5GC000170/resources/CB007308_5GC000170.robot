*** Settings ***
Documentation
...    Author: Natalia Grun (natalia.grun@nokia.com)
...    Maintainer: Natalia Grun (natalia.grun@nokia.com)
...    Group in charge: BTS_OAM_VERIF
...    References: doors
...    Feature Description: 5GC002056-AZ_5GC000952
...    Sample execution: /opt/ute/python/bin/pybot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/5GC002056-AZ_5GC000952/general.robot

Library         String
Library         Telnet
Library         OperatingSystem
Library         Process
#Library        Selenium2Library
Library         SSHLibrary
#Library         ute_fault
Library         ute_async
Library         collections
Library         XML  lxml=True
Library         ute_admin_infomodel


Resource    ../../resources/admin.robot
Resource    ../../resources/admin_infomodel.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot

Resource    ../../resources/fault_trigger.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

*** Variables ***
${fault_id_4383}=            4383
${EFaultId_4383}=            EFaultId_VirtualNodeNotRespondingAl
${source_fault4383}=         /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/CCU_L-1/SOC_L-1/SW_NODE_L-3
${reasoningStatus_4383}=     [stateInfo.reasoningStatus[?]="NodeStoppedUnexpectedly"]
${reasoning_path_4383}=      /MRBTS-1/RAT-1/BTS_L_1/EQM_L-1/CABINET_L-1/SMOD_L-1/CCU_L-1/SOC_L-1/SW_NODE_L-*
${RNCELL_path}=			     /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
${recovery_reset_ind_path}=  /MRBTS-1/RAT-1/FRI-1/RECOVERY_RESET_IND-1
${alarm_path}=               /MRBTS-1/RAT-1/FRI-1/ALARM-*
${alarm_severity_Critical}=  Critical
${alarm_number_7116}=        7116


${Delta_Set_actForceAutoReset_actForceUnitAutoReset_True}=
...        ${CURDIR}/../resources/Delta_Set_actForceAutoReset_actForceUnitAutoReset_True.json
${Delta_Set_actForceAutoReset_actForceUnitAutoReset_False}=
...        ${CURDIR}/../resources/Delta_Set_actForceAutoReset_actForceUnitAutoReset_False.json



*** Keywords ***
5GC000170_ASOE_Check_if_4th_Site_recovery_reset_within_1_hour_is_not_executed
        log to console  Start ASOE_Check_if_4th_Site_recovery_reset_within_1_hour_is_not_executed test

        admin.ADMIN Perform Delta Recommissioning
        ...                 delta_file=${Delta_Set_actForceAutoReset_actForceUnitAutoReset_True}
        ...                 skip_parameter_relation_errors=True

        log to console   trigger fault 4383 for 4 times in an hour
        FOR    ${INDEX}  IN RANGE    0   3
            log to console    ${${INDEX}+1} recovery action done
            Trigger 4383 and check increment counter
        END
        log to console    4 recovery action done
        Trigger 4383 for 4th time
        admin.ADMIN Reset Site
#        ADMIN Wait Until BTS OnAir
        Wait Until Keyword Succeeds  300s  10s  SYSTEM Check If Gnb Is Pingable
        Wait Until Keyword Succeeds  300s  10s  Check If BTS Is Not In Uncommissioned State
        Wait Until Keyword Succeeds  600s  10s  Check if RMOD is in availabilityStatus Online
#        Restart Wts for OnAir
        ADMIN Check BTS Configured
        ${variable_position}  ADMIN Get Smod Position
        log to console   ${variable_position}
        admin.ADMIN Perform Delta Recommissioning
        ...                 delta_file=${Delta_Set_actForceAutoReset_actForceUnitAutoReset_False}
        ...                 skip_parameter_relation_errors=True
        log to console  End ASOE_Check_if_4th_Site_recovery_reset_within_1_hour_is_not_executed test


5GC000170_ASOE_Check_if_Site_recovery_reset_counter_is_incremented_and_if_BTS_reaches_onAir_after_Site_reset
        log to console
        ...   Start ASOE_Check_if_Site_recovery_reset_counter_is_incremented_and_if_BTS_reaches_onAir_after_Site_reset
        admin.ADMIN Perform Delta Recommissioning
        ...                 delta_file=${Delta_Set_actForceAutoReset_actForceUnitAutoReset_True}
        ...                 skip_parameter_relation_errors=True
        log to console   trigger fault 4383
        ${restartCounter_before}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-${BTS_Side}/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter

        Trigger 4383 and check increment counter
        Wait Until Keyword Succeeds  300s  10s  Check If BTS Is Not In Uncommissioned State
        Wait Until Keyword Succeeds  300s  10s  Check if RMOD is in availabilityStatus Online
#        ADMIN Wait Until BTS OnAir
#        Check if Cell is in availabilityStatus Online
        ADMIN Check BTS Configured
#        ${mplaneResetReasonDetailed}    ADMIN INFOMODEL Get Parameter Value
#        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-${BTS_Side}/EQM_L-1/CABINET_L-1/SMOD_L-1
#        ...    dict_param=mplaneResetReasonDetailed
#        should be equal as strings   ${mplaneResetReasonDetailed}   Recovery
#        log to console   mplaneResetReasonDetailed: ${mplaneResetReasonDetailed}

        ${RestartCause}   ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-${BTS_Side}/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCause
        should be equal as strings  ${RestartCause}    SoftwareReset
        log to console   RestartCause: ${RestartCause}

        ${restartCounter_after}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-${BTS_Side}/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
        should be equal as integers   ${restartCounter_after}    ${${restartCounter_before}+1}
        log to console   restartCounter: ${restartCounter_after}
        admin.ADMIN Perform Delta Recommissioning
        ...                 delta_file=${Delta_Set_actForceAutoReset_actForceUnitAutoReset_False}
        ...                 skip_parameter_relation_errors=True

        log to console
        ...   End ASOE_Check_if_Site_recovery_reset_counter_is_incremented_and_if_BTS_reaches_onAir_after_Site_reset


5GC000170_ASOE_Check_if_Site_recovery_reset_counter_is_cleared_and_Check_if_transient_alarm_is_reported_in_WebEM
        log to console    Start
        ...   ASOE_Check_if_Site_recovery_reset_counter_is_cleared_and_Check_if_transient_alarm_is_reported_in_WebEM
        admin.ADMIN Perform Delta Recommissioning
        ...                 delta_file=${Delta_Set_actForceAutoReset_actForceUnitAutoReset_True}
        ...                 skip_parameter_relation_errors=True
        log to console   trigger fault 4383
        Trigger 4383 and check increment counter
        admin.ADMIN Reset Site
        Wait Until Keyword Succeeds  300s  10s  SYSTEM Check If Gnb Is Pingable
        Wait Until Keyword Succeeds  300s  10s  Check If BTS Is Not In Uncommissioned State
        Wait Until Keyword Succeeds  300s  10s  Check if RMOD is in availabilityStatus Online
#        Restart Wts for OnAir
#        ADMIN Wait Until BTS OnAir
#        Check if Cell is in availabilityStatus Online
        ADMIN Check BTS Configured
        ${restartCounter_after}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-${BTS_Side}/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
        should be equal as integers   ${restartCounter_after}   0
        log to console    RestartCounter value: ${restartCounter_after} after SiteReset

        log to console   trigger fault 4383
        Trigger 4383 and check increment counter
#        ADMIN Wait Until BTS OnAir
#        Check if Cell is in availabilityStatus Online
        log to console   Wait for 1 hour
        Sleep  61 min

        ${restartCounter_after}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-${BTS_Side}/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
        should be equal as integers   ${restartCounter_after}   0
        log to console    RestartCounter value: ${restartCounter_after} after 1 hour since BTS OnAir

        admin.ADMIN Perform Delta Recommissioning
        ...                 delta_file=${Delta_Set_actForceAutoReset_actForceUnitAutoReset_False}
        ...                 skip_parameter_relation_errors=True

        log to console    End
        ...   ASOE_Check_if_Site_recovery_reset_counter_is_cleared_and_Check_if_transient_alarm_is_reported_in_WebEM

Trigger 4383 and check increment counter
        #Check If BTS Is OnAir And Alarm 4383 Is Not Active
#        Check If BTS Is OnAir And Alarm Is Not Active    4383
        Check If BTS Is Configured And Alarm Is Not Active    4383
        ${restartCounter_before}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
#        Kill pmagent to trigger fault 4383
        Kill CCSDaemonExe process to trigger fault 4383
        ${status}    Run Keyword And Return Status
        ...        Wait Until Keyword Succeeds  100  0.1      ADMIN INFOMODEL Check Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/FRI-1/RECOVERY_RESET_IND-1
        ...    dict_param=recoveryFaultID
        ...    value=4383
        Wait Until Keyword Succeeds   100  0.1      ADMIN INFOMODEL Check Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/FRI-1/RECOVERY_RESET_IND-1
        ...    dict_param=type
        ...    value=Site
        Run keyword if   '${status}'=='False'
        ...         CB007308_5GC000170.ADMIN Check If Alarm Is Active With Timeout  fault_id=4383  severity=Warning   timeout=150
        ...    ELSE   run keyword and ignore error
        ...         CB007308_5GC000170.ADMIN Check If Alarm Is Active With Timeout  fault_id=4383  severity=Warning   timeout=150
#        Check If Recovery Action Is Performed
        Sleep  45s
        Wait Until Keyword Succeeds  300s  5s  Check if RMOD is in availabilityStatus NotInstalled
        Wait Until Keyword Succeeds  400s  10s  Check if RMOD is in availabilityStatus Online
#        Restart Wts for OnAir
        Sleep  400s
        ADMIN Check BTS Configured
        Sleep  20
        SYSTEM Check if fault is not in active raw alarm  4383   EFaultId_VirtualNodeNotRespondingAl
        ADMIN Check If Alarm Is Not Active  fault_id=4383
        ${restartCounter_after}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
        should be equal as integers   ${restartCounter_after}    ${${restartCounter_before}+1}
        log to console   restartCounter: ${restartCounter_after}


Trigger 4383 for 4th time
#        Check If BTS Is OnAir And Alarm 4383 Is Not Active
        Check If BTS Is Configured And Alarm Is Not Active    4383
        ${restartCounter_before}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-${BTS_Side}/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter

#        Kill pmagent to trigger fault 4383
#        Stop container to trigger fault 4383
        Kill CCSDaemonExe process to trigger fault 4383
        Sleep   60
        SYSTEM Check if fault is in active raw alarm  4383   EFaultId_VirtualNodeNotRespondingAl
        CB007308_5GC000170.ADMIN Check If Alarm Is Active With Timeout  fault_id=4383  severity=Critical   timeout=120

        ${restartCounter_after}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-${BTS_Side}/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
        should be equal   ${restartCounter_after}    ${restartCounter_before}

        Check if Cell is in availabilityStatus Failed


Kill pmagent to trigger fault 4383
    ${process_pid}=   SYSTEM Execute Command On gNB
    ...    command=ps aux | grep -i "pmagent" | egrep -v "grep|bash" | awk '{print $2}'
    ...    alias=${SYSTEM_ALIAS_ASIB}
    @{list_process_pid}=  split to lines  ${process_pid}
    SYSTEM Execute Command On gNB
    ...    command=kill -11 @{list_process_pid}[0]
    ...    alias=${SYSTEM_ALIAS_ASIB}


Stop container to trigger fault 4383
    SYSTEM Execute Command On gNB
    ...    command=systemctl stop hwr-container@TRACECM00.service


Kill CCSDaemonExe process to trigger fault 4383
    SYSTEM Execute Command On gNB
    ...    command=pkill -11 -f '/opt/CCS/CCSDaemonExe --startup=nid=0x1510'
#    Run Keyword If  '${trunk_flag}'=='9999'   SYSTEM Execute Command On gNB
#    ...    command=pkill -11 -f '/opt/CCS/CCSDaemonExe --startup=nid=0x1510'
#    ...   ELSE    SYSTEM Execute Command On gNB
#    ...    command=systemctl stop hwr-container@TRACECM00.service


Check if Cell is in availabilityStatus Failed
    ${status}  Run Keyword And Return Status  ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/NRBTS_R-1/NRCELL_R-1
    ...      value=Failed
    Run Keyword Unless  ${status}  ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/NRBTS_R-1/NRCELL_R-1
    ...      value=failed

Check if Cell is in availabilityStatus Online
    ${status}  Run Keyword And Return Status  ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/NRBTS_R-1/NRCELL_R-1
    ...      value=Online
    Run Keyword Unless  ${status}  ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/NRBTS_R-1/NRCELL_R-1
    ...      value=none

Check if BBMOD is in availabilityStatus Offline
#    [Arguments]      ${timeout}=30s
    ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/CABINET_R-1/BBMOD_R-1
    ...      value=Offline

Check if BBMOD is in availabilityStatus Online
#    [Arguments]      ${timeout}=30s
    ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/CABINET_R-1/BBMOD_R-1
    ...      value=Online

Check if SMOD is in availabilityStatus Failed
#    [Arguments]      ${timeout}=30s
    ${status}  Run Keyword And Return Status  ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/CABINET_R-1/SMOD_R-1
    ...      value=Failed
    Run Keyword Unless  ${status}  ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/CABINET_R-1/SMOD_R-1
    ...      value=failed

Check if SMOD is in availabilityStatus Online
#    [Arguments]      ${timeout}=30s
    ${status}  Run Keyword And Return Status   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/CABINET_R-1/SMOD_R-1
    ...      value=Online
    Run Keyword Unless  ${status}  ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/CABINET_R-1/SMOD_R-1
    ...      value=none

Check if RMOD is in availabilityStatus NotInstalled
#    [Arguments]      ${timeout}=30s
    ${status}  Run Keyword And Return Status  ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/RMOD_R-1
    ...      value=NotInstalled
    Run Keyword Unless  ${status}  ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/RMOD_R-1
    ...      value=not installed

Check if RMOD is in availabilityStatus Online
#    [Arguments]      ${timeout}=30s
    ${status}  Run Keyword And Return Status   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/RMOD_R-1
    ...      value=Online
    Run Keyword Unless  ${status}  ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-${BTS_Side}/MRBTS_R-${BTS_Side}/EQM_R-${BTS_Side}/APEQM_R-1/RMOD_R-1
    ...      value=none


ADMIN Is alarm active and get severity
    [Arguments]
    ...         ${fault_id}
    ...         ${severity}
    ...         ${connection}=${ADMIN_ALIAS}
    @{out_alarms_objects_list}    ADMIN Get Active Alarms   ${connection}
    FOR    ${alarm}    IN    @{out_alarms_objects_list}
        ${dict_fault_id}    Get From Dictionary   ${alarm}    faultId
        ${dict_severity}    Get From Dictionary   ${alarm}    severity
        ${dict_faultName}   Get From Dictionary   ${alarm}   faultName  #'BTS site autonomous reset as recovery action'
        Run Keyword If    '${dict_fault_id}' == '${fault_id}'
    ...       Run Keyword If    '${dict_severity}' == '${severity}'
    ...           Run Keywords     log to console   Fault ${dict_fault_id} - ${dict_severity} - ${dict_faultName}
    ...              AND           return from keyword    ${TRUE}
    END
    return from keyword    ${FALSE}

ADMIN Check If Alarm Is Active and severity
    [Arguments]    ${fault_id}
    ...            ${severity}
    ...            ${connection}=${ADMIN_ALIAS}
    ${is_active}    ADMIN Is alarm active and get severity  ${fault_id}   ${severity}   ${connection}
    Should Be True   ${is_active}

ADMIN Check If Alarm Is Active With Timeout
    [Arguments]    ${fault_id}
    ...            ${severity}
    ...            ${timeout}
    wait until keyword succeeds  ${timeout}  0.1  ADMIN Check If Alarm Is Active and severity   ${fault_id}  ${severity}


Verify if Alarm Managed Object for '${fault_id}' is not in Info Model
    ute_admin_infomodel.Query infomodel  query=count ${alarm_path} is [faultId=${fault_id}] = 0  timeout=60

Restart Wts for OnAir
        Reach onAir Teardown
        ute_wts_runner.Start UTE WTS
        X2 Connection

Branch or Trunk
    ${split_build}=  Split String  ${OUT_ACTIVE_SW}  separator=\_
    ${trunk_flag}=   Get from list  ${split_build}   2
    Set Suite Variable  ${trunk_flag}
    ${sw_version}=   Get from list  ${split_build}   0
    Set Suite Variable  ${sw_version}
