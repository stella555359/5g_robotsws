*** Settings ***
Documentation
...    Author: Zaharia Andreea-Oana (andreea-oana.zaharia@nokia.com)
...    Maintainer: Zaharia Andreea-Oana (andreea-oana.zaharia@nokia.com)
...    Group in charge: BTS_OAM_VERIF_ET4
...    References: doors
...    Feature Description: CNI-87105
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/MN/UTE/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CNI-87105/general.robot

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
#Resource    ../../../resources/AirPhone/resources/fs_tdd_sansa_ecpri_cmwv_ASOE/SBTS00
Resource    ../../resources/AirPhone/resources/ute/coam.robot
Resource    ../../resources/AirPhone/resources/ute/ute_wts_runner.robot


*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

*** Variables ***
${fault_id_9102}=            9102
${EFaultId_9102}=            EFaultId_RfoeMhabRecoveryAl
${source_fault4383}=         /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/CABINET_L-1/SMOD_L-1/CCU_L-1/SOC_L-1/SW_NODE_L-3
${reasoningStatus_4383}=     [stateInfo.reasoningStatus[?]="NodeStoppedUnexpectedly"]
${reasoning_path_4383}=      /MRBTS-1/RAT-1/BTS_L-4/HWTOP_L-1/CABLNK_L-*
${RNCELL_path}=			     /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
${recovery_reset_ind_path}=  /MRBTS-1/RAT-1/FRI-1/RECOVERY_RESET_IND-1
${alarm_path}=               /MRBTS-1/RAT-1/FRI-1/ALARM-*
${alarm_severity_Critical}=  Critical
${alarm_number_7116}=        7116

${RECOVERY_RESET_IND}=      /MRBTS-1/RAT-1/FRI-4/RECOVERY_RESET_IND-1


${Delta_Set_actForceAutoReset_actForceUnitAutoReset_True}=
...        ${CURDIR}/../resources/Delta_Set_actForceAutoReset_actForceUnitAutoReset_True.json
${Delta_Set_actForceAutoReset_actForceUnitAutoReset_False}=
...        ${CURDIR}/../resources/Delta_Set_actForceAutoReset_actForceUnitAutoReset_False.json


*** Keywords ***
Fault_9102_Check_if_7th_RF_recovery_ action_is_not_executed_within_one_hour
#        log to console  Start
#        ADMIN Check BTS OnAir
#        admin.ADMIN Perform Delta Recommissioning
#        ...                 delta_file=${Delta_Set_actForceAutoReset_actForceUnitAutoReset_True}
#        ...                 skip_parameter_relation_errors=True
#        log to console   trigger fault 9102 for 7 times in an hour
       FOR    ${INDEX}  IN RANGE    0   1
           log to console    ${${INDEX}+1} recovery action ongoing
           Trigger 9102 fault for 6th times
           log to console    ${${INDEX}+1} recovery action done
       END
#        log to console    trigger 7th recovery action - not performed
#        Trigger 9102 for 7th time
#        log to console  BTS reset to clear critical alarm
#        admin.ADMIN Reset Site
#        sleep  60
#        Wait Until Keyword Succeeds  300s  10s  SYSTEM Check If Gnb Is Pingable
#        Wait Until Keyword Succeeds  400s  10s  Check if RMOD is in availabilityStatus Online
#        ADMIN Wait Until BTS OnAir
#        admin.ADMIN Perform Delta Recommissioning
#        ...                 delta_file=${Delta_Set_actForceAutoReset_actForceUnitAutoReset_False}
#        ...                 skip_parameter_relation_errors=True
#        log to console  End

Trigger 9102 fault for 6th times
        Check If BTS Is OnAir And Alarm Is Not Active  9102
        Trigger 9102 fault
#        ${status}    Run Keyword And Return Status
#        ...        Wait Until Keyword Succeeds  100  0.1      ADMIN INFOMODEL Check Parameter Value
#        ...    dist_name=/MRBTS-1/RAT-1/FRI-4/RECOVERY_RESET_IND-5
#        ...    dict_param=recoveryFaultID
#        ...    value=9102
#        Wait Until Keyword Succeeds   100  0.1      ADMIN INFOMODEL Check Parameter Value
#        ...    dist_name=/MRBTS-1/RAT-1/FRI-4/RECOVERY_RESET_IND-5
#        ...    dict_param=type
#        ...    value=Warm
         CNI87105.ADMIN Check If supplAlarmInfo Field Exists With Timeout   fault_id=9102
         ...  supplAlarmInfo=RFOE recovery successfully performed on RF1, affecting additional ports: RF2,RF3,RF4   timeout=60
        CNI87105.ADMIN Check If Alarm Is Active With Timeout  fault_id=9102  severity=Warning   timeout=150
        Wait Until Keyword Succeeds  300s  2s  Check if RMOD is in availabilityStatus Offline
        CNI87105.Check if Cell is in availabilityStatus Failed
        Wait Until Keyword Succeeds  400s  10s  Check if RMOD is in availabilityStatus Online
        ADMIN Wait Until BTS OnAir
        SYSTEM Check if fault is not in active raw alarm  9102   EFaultId_RfoeMhabRecoveryAl
        ADMIN Check If Alarm Is Not Active  fault_id=9102

Trigger 9102 for 7th time
        Check If BTS Is OnAir And Alarm Is Not Active  9102
        Trigger 9102 fault
        Sleep   10
        Check if RMOD is in availabilityStatus Online
        CNI87105.Check if Cell is in availabilityStatus Failed
        SYSTEM Check if fault is in active raw alarm  9102   EFaultId_RfoeMhabRecoveryAl
        CNI87105.ADMIN Check If Alarm Is Active With Timeout  fault_id=9102  severity=Critical   timeout=60
        CNI87105.ADMIN Check If supplAlarmInfo Field Exists With Timeout  fault_id=9102
        ...     supplAlarmInfo=RFOE recovery successfully performed on RF1, affecting additional ports: RF2,RF3,RF4  timeout=60

Trigger 9102 fault
    [Arguments]    ${hostname}=192.168.255.1
    ...            ${username}=toor4nsn
    ...            ${password}=oZPS0POrRieRtu
    SSHLibrary.Open connection  host=${hostname}      alias=${SYSTEM_ALIAS_ASIB}
    SSHLibrary.Login  username=${username}  password=${password}       delay=2s
    SSHLibrary.Write  bsh 1:1
    SSHLibrary.Write  confmgmtbrowser write FrontHaul rdCgxFifoFullOperations 3
    Sleep  5
    SSHLibrary.Close_connection

Check if Cell is in availabilityStatus Failed
    #[Arguments]      ${timeout}=90s
    ${status1}   Run Keyword And Return Status   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1
    ...      value=Failed
     Run Keyword Unless   ${status1}   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
    ...      value=Failed


Check if Cell is in availabilityStatus Online
    #[Arguments]      ${timeout}=90s
     ${status1}   Run Keyword And Return Status  ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/NRBTS_R-1/NRCELL_R-1
    ...      value=None
     Run Keyword Unless   ${status1}   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
    ...      value=None


Check if RMOD is in availabilityStatus Offline
    #[Arguments]      ${timeout}=90s
    ${status1}   Run Keyword And Return Status   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1
    ...      value=off line
    Run Keyword Unless   ${status1}   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-4/APEQM_R-1/RMOD_R-1
    ...      value=off line

Check if RMOD is in availabilityStatus Online
    #[Arguments]      ${timeout}=60s
    ${status1}   Run Keyword And Return Status   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1
    ...      value=None
    Run Keyword Unless   ${status1}   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-4/APEQM_R-1/RMOD_R-1
    ...      value=None

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
    wait until keyword succeeds  ${timeout}  0.2  ADMIN Check If Alarm Is Active and severity   ${fault_id}  ${severity}



ADMIN Is alarm active and get supplAlarmInfo
    [Arguments]
    ...         ${fault_id}
    ...         ${supplAlarmInfo}
    ...         ${connection}=${ADMIN_ALIAS}
    @{out_alarms_objects_list}    ADMIN Get Active Alarms   ${connection}
    FOR    ${alarm}    IN    @{out_alarms_objects_list}
        ${dict_fault_id}    Get From Dictionary   ${alarm}    faultId
        Run Keyword If    '${dict_fault_id}' == '${fault_id}'
    ...       ${dict_supplAlarmInfo}    Get From Dictionary   ${alarm}    supplAlarmInfo
        Run Keyword If    '${dict_supplAlarmInfo}' == '${supplAlarmInfo}'
    ...           Run Keywords     log to console   Fault ${dict_fault_id} - ${dict_supplAlarmInfo}
    ...              AND           return from keyword    ${TRUE}
    END
    return from keyword    ${FALSE}

ADMIN Check If Alarm Is Active and supplAlarmInfo
    [Arguments]    ${fault_id}
    ...            ${supplAlarmInfo}
    ...            ${connection}=${ADMIN_ALIAS}
    ${is_active}    ADMIN Is alarm active and get supplAlarmInfo  ${fault_id}   ${supplAlarmInfo}   ${connection}
    Should Be True   ${is_active}

ADMIN Check If supplAlarmInfo Field Exists With Timeout
    [Arguments]    ${fault_id}
    ...            ${supplAlarmInfo}
    ...            ${timeout}
    wait until keyword succeeds  ${timeout}  0.2  ADMIN Check If Alarm Is Active and supplAlarmInfo   ${fault_id}  ${supplAlarmInfo}
