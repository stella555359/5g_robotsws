*** Settings ***
Documentation
...    Author: Natalia Grun (natalia.grun@nokia.com)
...    Maintainer: Natalia Grun (natalia.grun@nokia.com)
...    Group in charge: RAN_BOAM_VERIF
...    References: doors
...    Feature Description: 5GC001638-BA-a2_5GC000952-A-a2
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/  testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB000829-A-00/5GC001638-BA-a2_5GC000952-A-a2/general.robot

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


Resource    ../../../resources/admin.robot
Resource    ../../../resources/admin_infomodel.robot
Resource    ../../../resources/selenium.robot
Resource    ../../../resources/pretest_posttest.robot
Resource    ../../../resources/system.robot

Resource    ../../../resources/fault_trigger.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${SW_DESTINATION}     /home/ute

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

5GC001638-BA_Check_if_FSP_recovery_reset_counter_is_cleared_after_1_hour_and_after_Site_reset
#        log to console    Start
#        ...     5GC000952_ASIL_ABIO_Check_if_FSP_recovery_reset_counter_is_cleared_after_1_hour_and_after_Site_reset

        SYSTEM Add Flag In Swconfig File without Site Reset    0x500001=0      # ${SYSTEM_ALIAS_ASIL}
        ADMIN Reset Site
        ADMIN Wait Until BTS OnAir

        admin.ADMIN Perform Delta Recommissioning
        ...                 delta_file=${Delta_Set_actForceAutoReset_actForceUnitAutoReset_True}
        ...                 skip_parameter_relation_errors=True

        log to console   trigger fault 4019 - twice
        ${cnt}=   Trigger 4019 and check increment counter   0
        ${cnt1}=  Trigger 4019 and check increment counter   ${cnt}
        log to console    BBMOD Recovery reset counter value: ${cnt1} before SiteReset

        admin.ADMIN Reset Site
        ADMIN Wait Until BTS OnAir
        Sleep  10s
        5GC001638-BA-a2_5GC000952-A-a2.ADMIN INFOMODEL Check if Cell is in availabilityStatus Online

        log to console   trigger fault 4019 - twice
        ${cnt}=   Trigger 4019 and check increment counter   0
        log to console    BBMOD Recovery reset counter value: ${cnt} after SiteReset
        ${cnt1}=  Trigger 4019 and check increment counter   ${cnt}
        log to console    BBMOD Recovery reset counter value: ${cnt1} before wait for 1 hour
        ADMIN Wait Until BTS OnAir
        Sleep  10s
        5GC001638-BA-a2_5GC000952-A-a2.ADMIN INFOMODEL Check if Cell is in availabilityStatus Online

        log to console   Wait for 1 hour
        Sleep  61 min

        ${restartCounter_after}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-${BTS_Side}/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
        should be equal as integers   ${restartCounter_after}   0

        ${cnt}=   Trigger 4019 and check increment counter   0
        log to console    BBMOD Recovery reset counter value: ${cnt} after 1 hour since BTS OnAir

        admin.ADMIN Perform Delta Recommissioning
        ...                 delta_file=${Delta_Set_actForceAutoReset_actForceUnitAutoReset_False}
        ...                 skip_parameter_relation_errors=True

Restart Wts for OnAir
        Reach onAir Teardown
        ute_wts_runner.Start UTE WTS
        X2 Connection


Trigger 4019 and check increment counter
        [Arguments]    ${counter_value_before}
        Check If BTS Is OnAir And Alarm Is Not Active    4019

        Killall HWRTimeSExe to trigger fault 4019
        Sleep  30
        Wait Until Keyword Succeeds   360  5   ADMIN Get Object Distname From Class Name  RECOVERY_RESET_IND
        ${recovery_reset_ind}=  ADMIN Get Object Distname From Class Name   RECOVERY_RESET_IND
        log to console   recovery_reset_ind object: ${recovery_reset_ind}
        ${status}    Run Keyword And Return Status
        ...        Wait Until Keyword Succeeds  30  0.3   ADMIN INFOMODEL Check Parameter Value
        ...    dist_name=${recovery_reset_ind}       #/MRBTS-1/RAT-1/FRI-${BTS_Side}/RECOVERY_RESET_IND-1
        ...    dict_param=recoveryFaultID
        ...    value=4019
        Run keyword if   '${status}'=='False'
        ...         5GC001638-BA-a2_5GC000952-A-a2.ADMIN Check If Alarm Is Active With Timeout  fault_id=4019  severity=Warning   timeout=100
        ...    ELSE   run keyword and ignore error
        ...         5GC001638-BA-a2_5GC000952-A-a2.ADMIN Check If Alarm Is Active With Timeout  fault_id=4019  severity=Warning   timeout=100

        Wait Until Keyword Succeeds   150   5   5GC001638-BA-a2_5GC000952-A-a2.ADMIN INFOMODEL Check if BBMOD is in availabilityStatus Offline
        Wait Until Keyword Succeeds    30   5    5GC001638-BA-a2_5GC000952-A-a2.ADMIN INFOMODEL Check if RMOD is in availabilityStatus NotInstalled
        log to console   sleep 30
        Sleep   30
        SYSTEM Check if fault is not in active raw alarm  4019   EFaultId_KeepAliveStatusErrorAl
        ADMIN Check If Alarm Is Not Active  fault_id=4019

#        log to console   reboot Iphy
#        SYSTEM Execute Command On IPHY  ddal -s ddal_reboot_graceful
#        SYSTEM Wait Till Iphy Will Not Be Pingable For A Given Period
#        Sleep  60
#        SYSTEM Wait For Host Is Reachable With Ping  192.168.200.1
#        Sleep  250
# #       Restart Wts for OnAir

        Wait Until Keyword Succeeds   140   5   5GC001638-BA-a2_5GC000952-A-a2.ADMIN INFOMODEL Check if BBMOD is in availabilityStatus Online
        Wait Until Keyword Succeeds   350   5   5GC001638-BA-a2_5GC000952-A-a2.ADMIN INFOMODEL Check if RMOD is in availabilityStatus Online

        ${counter_value_after}=   Get BBMOD recovery reset counter value from syslog
        Run keyword if   '${counter_value_after}'>'0'
        ...       should be equal as integers   ${counter_value_after}    ${${counter_value_before}+1}

        Wait Until Keyword Succeeds     420    5     ADMIN INFOMODEL Check If BTS Is OnAir

        [Return]    ${counter_value_after}


Get BBMOD recovery reset counter value from syslog

        Run    cat -v /tmp/btslog2/S* > /opt/ute/concatenate_syslog.log
        Run    grep -irn "Reset counter for" /opt/ute/concatenate_syslog.log > /tmp/syslog_recov_counter.log
        Run    rm /opt/ute/concatenate_syslog.log

         ${grep_content}=  Run    cat /tmp/syslog_recov_counter.log
        log to console    cat \${grep_content}=${grep_content}

        ${grep_content_split}=    Split string     ${grep_content}    separator=\is:
        ${counter_value_last_line}=   Get from list   ${grep_content_split}   -1    # last element
        ${counter_value}=  get_substring   ${counter_value_last_line}  1  2         # return the second character
#                 split to lines   $string   -1 0     # last line
        ${counter_value_after}=      Convert To Integer   ${counter_value}
        log to console   value BBMOD recovery reset counter after: ${counter_value_after}

        [Return]    ${counter_value_after}


Killall HWRTimeSExe to trigger fault 4019
    [Arguments]    ${hostname}=192.168.255.1
    ...            ${username}=toor4nsn
    ...            ${password}=oZPS0POrRieRtu
    SSHLibrary.Open connection  host=${hostname}      alias=${SYSTEM_ALIAS_ASIB}
    SSHLibrary.Login  username=${username}  password=${password}       delay=2s
    SSHLibrary.Write  bsh 1:0
    SSHLibrary.Write  killall /opt/hwr/HWRTimeSExe
    Sleep  2
    SSHLibrary.Close_connection


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
    wait until keyword succeeds  ${timeout}  0.5  5GC001638-BA-a2_5GC000952-A-a2.ADMIN Check If Alarm Is Active and severity
    ...                                                                         ${fault_id}  ${severity}

Verify if Alarm Managed Object for '${fault_id}' is not in Info Model
    ute_admin_infomodel.Query infomodel  query=count ${alarm_path} is [faultId=${fault_id}] = 0  timeout=60


ADMIN INFOMODEL Check if Cell is in availabilityStatus Failed
#    Run Keyword Unless   ${status}
    ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-0
    ...      value=failed

ADMIN INFOMODEL Check if Cell is in availabilityStatus Online
    ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-0
    ...      value=None

ADMIN INFOMODEL Check if BBMOD is in availabilityStatus Offline
    #[Arguments]      ${timeout}=30s
    ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-3
    ...      value=off line

ADMIN INFOMODEL Check if BBMOD is in availabilityStatus Online
    #[Arguments]      ${timeout}=30s
    ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-3
    ...      value=None

ADMIN INFOMODEL Check if RMOD is in availabilityStatus NotInstalled
    #[Arguments]      ${timeout}=30s
    ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...      value=not installed

ADMIN INFOMODEL Check if RMOD is in availabilityStatus Online
    #[Arguments]      ${timeout}=30s
    ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...      value=None


UTE TL Preparation
    [Documentation]     Keyword used for setting up local 5G TLs to onAir state, as UTE reserve it only to sw_upload state
    #TO DO:             Add Check for onAir State. For cases when the Suite is run more than one time
    PREPOST Setup Admin
    ADMIN Change R&D Port Status    status=True
    @{status}   Run Keyword and Ignore Error    ADMIN Check BTS onair
    Run Keyword If  '@{status}[0]' == 'FAIL'   Run Keyword  5GC001638-BA-a2_5GC000952-A-a2.Configured_SwDownload_SwUpdate_OnAir
    ...     ELSE    Log To Console  --- BTS already onAir ---
    PREPOST Teardown Admin

Configured_SwDownload_SwUpdate_OnAir
    ADMIN Check BTS Not Commisioned
    Get TL Hostname
    Get Software Release
    ADMIN Perform Commissioning
    ...     scf_file=/home/ute/MN/UTE/robotws/custom-config/Timisoara/${tl_hostname}/${sw_release}/${tl_hostname}_SCF.xml
    ${configured}   Run Keyword and Return Status    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    Run Keyword If  '${configured}' == 'True'  Sleep  180
    Run Keyword Unless   ${configured}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Check BTS Configured
    ...    AND     Sleep  180
    Log To Console  Fault ID23 Checking...
    ${result}   Run Keyword and Return Status    ADMIN Check If Alarm Is Active  fault_id=23
    BuiltIn.Run Keyword If  '${result}' == 'True'   Run Keywords   Log To Console  Fault ID23 found. Start RF Software Update
    ...     AND     ADMIN Download And Update Current Software
    ...     ELSE    Log To Console  Fault ID23 not found.
    ${onair}   Run Keyword and Return Status    BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir
    Run Keyword Unless   ${onair}   Run Keywords   admin.ADMIN Reset Site
    ...    AND     BuiltIn.Wait Until Keyword Succeeds  600  30   ADMIN Wait Until BTS OnAir

