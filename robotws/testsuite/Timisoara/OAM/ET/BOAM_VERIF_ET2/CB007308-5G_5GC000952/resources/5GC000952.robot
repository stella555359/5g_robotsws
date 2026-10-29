*** Settings ***
Documentation
...    Author: Zaharia Andreea-Oana (andreea-oana.zaharia@nokia.com)
...    Maintainer: Zaharia Andreea-Oana (andreea-oana.zaharia@nokia.com)
...    Group in charge: BTS_OAM_VERIF
...    References: doors
...    Feature Description: CB007380-5G_5GC000952
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws5g/testsuite/OAM/ET/BTS_OAM_FMRECOV/CB007308-5G_5GC000952/general.robot

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
#Resource    ../../resources/AirPhone/resources/fs_tdd_sansa_ecpri_cmwv_ASOE/SBTS00
Resource    ../../resources/AirPhone/resources/ute/coam.robot
Resource    ../../resources/AirPhone/resources/ute/ute_wts_runner.robot


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
5GC000952_ASOE_Check_if_4th_Site_recovery_reset_within_1_hour_is_not_executed
        log to console  Start ASOE_Check_if_4th_Site_recovery_reset_within_1_hour_is_not_executed test
        ADMIN Wait Until BTS OnAir
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
#        Wait Until Keyword Succeeds  300s  1s  SYSTEM Check If Gnb Is Not Pingable
        Wait Until Keyword Succeeds  300s  10s  SYSTEM Check If Gnb Is Pingable
        Wait Until Keyword Succeeds  300s  10s  Check If BTS Is Not In Uncommissioned State
        Wait Until Keyword Succeeds  300s  10s  Check if RMOD is in availabilityStatus Online
        Restart Wts for OnAir
        Sleep  10
#        Check if Cell is in availabilityStatus Online
        admin.ADMIN Perform Delta Recommissioning
        ...                 delta_file=${Delta_Set_actForceAutoReset_actForceUnitAutoReset_False}
        ...                 skip_parameter_relation_errors=True
        log to console  End ASOE_Check_if_4th_Site_recovery_reset_within_1_hour_is_not_executed test


5GC000952_ASOE_Check_if_Site_recovery_reset_counter_is_incremented_and_if_BTS_reaches_onAir_after_Site_reset
        log to console
        ...    Start  ASOE_Check_if_Site_recovery_reset_counter_is_incremented_and_if_BTS_reaches_onAir
        admin.ADMIN Perform Delta Recommissioning
        ...                 delta_file=${Delta_Set_actForceAutoReset_actForceUnitAutoReset_True}
        ...                 skip_parameter_relation_errors=True
        log to console   trigger fault 4383
        ${restartCounter_before}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
        Trigger 4383 and check increment counter
        Wait Until Keyword Succeeds  300s  10s  Check If BTS Is Not In Uncommissioned State
        Wait Until Keyword Succeeds  300s  10s  Check if RMOD is in availabilityStatus Online
        Restart Wts for OnAir
#        ADMIN Wait Until BTS OnAir
#        Check if Cell is in availabilityStatus Online
        ${mplaneResetReasonDetailed}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=mplaneResetReasonDetailed
        should be equal as strings   ${mplaneResetReasonDetailed}   Recovery
        log to console   mplaneResetReasonDetailed: ${mplaneResetReasonDetailed}
        ${RestartCause}   ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCause
        should be equal as strings  ${RestartCause}    SoftwareReset
        log to console   RestartCause: ${RestartCause}
        ${restartCounter_after}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
        should be equal as integers   ${restartCounter_after}    ${${restartCounter_before}+1}
        log to console   restartCounter: ${restartCounter_after}
        admin.ADMIN Perform Delta Recommissioning
        ...                 delta_file=${Delta_Set_actForceAutoReset_actForceUnitAutoReset_False}
        ...                 skip_parameter_relation_errors=True
        log to console
        ...   End ASOE_Check_if_Site_recovery_reset_counter_is_incremented_and_if_BTS_reaches_onAir
#        admin.ADMIN Reset Site
##        Wait Until Keyword Succeeds  300s  1s  SYSTEM Check If Gnb Is Not Pingable
#        Wait Until Keyword Succeeds  300s  10s  SYSTEM Check If Gnb Is Pingable
#        Wait Until Keyword Succeeds  300s  10s  Check If BTS Is Not In Uncommissioned State
#        Wait Until Keyword Succeeds  300s  10s  Check if RMOD is in availabilityStatus Online
#        Restart Wts for OnAir
#        ADMIN Wait Until BTS OnAir


5GC000952_ASOE_Check_if_Site_recovery_reset_counter_is_cleared_and_Check_if_transient_alarm_is_reported_in_WebEM
        log to console    Start
        ...     ASOE_Check_if_Site_recovery_reset_counter_is_cleared_and_Check_if_transient_alarm_reported
        admin.ADMIN Perform Delta Recommissioning
        ...                 delta_file=${Delta_Set_actForceAutoReset_actForceUnitAutoReset_True}
        ...                 skip_parameter_relation_errors=True
        log to console   trigger fault 4383
         ${restartCounter_before}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
        Trigger 4383 and check increment counter
        admin.ADMIN Reset Site
#        Wait Until Keyword Succeeds  300s  1s  SYSTEM Check If Gnb Is Not Pingable
        Wait Until Keyword Succeeds  300s  10s  SYSTEM Check If Gnb Is Pingable
        Wait Until Keyword Succeeds  300s  10s  Check If BTS Is Not In Uncommissioned State
        Wait Until Keyword Succeeds  300s  10s  Check if RMOD is in availabilityStatus Online
        Restart Wts for OnAir
#        ADMIN Wait Until BTS OnAir
#        Check if Cell is in availabilityStatus Online
        ${restartCounter_after}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
        should be equal as integers   ${restartCounter_after}   0
        log to console    RestartCounter value: ${restartCounter_after} after SiteReset
        log to console   trigger fault 4383
        Trigger 4383 and check increment counter
#        ADMIN Wait Until BTS OnAir
#        Check if Cell is in availabilityStatus Online
        sleep  60
        ${restartCounter_after}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
        should be equal as integers   ${restartCounter_after}    ${${restartCounter_before}+1}
        log to console   restartCounter: ${restartCounter_after}
        log to console   Wait for 1 hour
        Sleep  61 min
        ${restartCounter_after}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
        should be equal as integers   ${restartCounter_after}   0
        log to console    RestartCounter value: ${restartCounter_after} after 1 hour since BTS OnAir
        admin.ADMIN Perform Delta Recommissioning
        ...                 delta_file=${Delta_Set_actForceAutoReset_actForceUnitAutoReset_False}
        ...                 skip_parameter_relation_errors=True
        log to console    End
        ...   ASOE_Check_if_Site_recovery_reset_counter_is_cleared_and_Check_if_transient_alarm_reported



Trigger 4383 and check increment counter
        Check If BTS Is OnAir And Alarm Is Not Active    4383
        ${restartCounter_before}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
        Kill pmagent to trigger fault 4383
        ${status}    Run Keyword And Return Status
        ...        Wait Until Keyword Succeeds  100  0.3      ADMIN INFOMODEL Check Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/FRI-1/RECOVERY_RESET_IND-1
        ...    dict_param=recoveryFaultID
        ...    value=4383
        Run keyword if   '${status}'=='False'
        ...         5GC000952.ADMIN Check If Alarm Is Active With Timeout  fault_id=4383  severity=Warning   timeout=90
        ...    ELSE   run keyword and ignore error
        ...         5GC000952.ADMIN Check If Alarm Is Active With Timeout  fault_id=4383  severity=Warning   timeout=90
        Check If Recovery Action Is Performed
        Sleep  45s
        Wait Until Keyword Succeeds  300s  5s  Check if RMOD is in availabilityStatus NotInstalled
        Wait Until Keyword Succeeds  300s  10s  Check if RMOD is in availabilityStatus Online
        Restart Wts for OnAir
        Sleep  20
#        run keyword and continue on failure     ADMIN Wait Until BTS OnAir
        SYSTEM Check if fault is not in active raw alarm  4383   EFaultId_VirtualNodeNotRespondingAl
        ADMIN Check If Alarm Is Not Active  fault_id=4383
        ${restartCounter_after}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
        should be equal as integers   ${restartCounter_after}    ${${restartCounter_before}+1}
        log to console   restartCounter: ${restartCounter_after}

Trigger 4383 for 4th time
        Check If BTS Is OnAir And Alarm Is Not Active   4383
        ${restartCounter_before}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
        Kill pmagent to trigger fault 4383
        Sleep   60
        SYSTEM Check if fault is in active raw alarm  4383   EFaultId_VirtualNodeNotRespondingAl
        5GC000952.ADMIN Check If Alarm Is Active With Timeout  fault_id=4383  severity=Critical   timeout=90
        ${restartCounter_after}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
        should be equal   ${restartCounter_after}    ${restartCounter_before}
        Check if Cell is in availabilityStatus Failed


Kill pmagent to trigger fault 4383
    ${process_pid}=   SYSTEM Execute Command On gNB
    ...    command=ps aux | grep -i "pmagent" | egrep -v "grep|bash" | awk '{print $2}'
    ...    alias=${SYSTEM_ALIAS_ASIL}
    @{list_process_pid}=  split to lines  ${process_pid}
    SYSTEM Execute Command On gNB
    ...    command=kill -11 @{list_process_pid}[0]
    ...    alias=${SYSTEM_ALIAS_ASIL}

Check if Cell is in availabilityStatus Failed
    ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
    ...      value=Failed
    ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-2
    ...      value=Failed

Check if Cell is in availabilityStatus Online
    ${status1}   Run Keyword And Return Status   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
    ...      value=Online
    Run Keyword Unless   ${status1}   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
    ...      value=None
    ${status2}   Run Keyword And Return Status   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-2
    ...      value=Online
    Run Keyword Unless   ${status2}   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-2
    ...      value=None

Check if RMOD is in availabilityStatus NotInstalled
    #[Arguments]      ${timeout}=90s
    ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...      value=NotInstalled
    ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-2
    ...      value=NotInstalled

Check if RMOD is in availabilityStatus Online
    #[Arguments]      ${timeout}=60s
    ${status1}   Run Keyword And Return Status   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...      value=Online
    Run Keyword Unless   ${status1}   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...      value=None
    ${status2}   Run Keyword And Return Status   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-2
    ...      value=Online
    Run Keyword Unless   ${status2}   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-2
    ...      value=None


ADMIN Is alarm active and get severity
    [Arguments]
    ...         ${fault_id}
    ...         ${severity}
    ...         ${connection}=${ADMIN_ALIAS}
    @{out_alarms_objects_list}    ADMIN Get Active Alarms   ${connection}
        FOR    ${alarm}    IN    @{out_alarms_objects_list}
        ${dict_fault_id}    Get From Dictionary    ${alarm}    faultId
        ${dict_severity}    Get From Dictionary    ${alarm}    severity
        ${dict_faultName}   Get From Dictionary    ${alarm}    faultName  #'BTS site autonomous reset as recovery action'

        IF    '${dict_fault_id}' == '${fault_id}' and '${dict_severity}' == '${severity}'
                Log To Console    Fault ${dict_fault_id} - ${dict_severity} - ${dict_faultName}
                RETURN    ${TRUE}
        END
        END

        RETURN    ${FALSE}


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
    wait until keyword succeeds  ${timeout}  0.2  ADMIN Check If Alarm Is Active and severity   ${fault_id}  ${severity}


Verify if Alarm Managed Object for '${fault_id}' is not in Info Model
    ute_admin_infomodel.Query infomodel  query=count ${alarm_path} is [faultId=${fault_id}] = 0  timeout=60

Restart Wts for OnAir
    Reach onAir Teardown
    ute_wts_runner.Start UTE WTS
    X2 Connection
