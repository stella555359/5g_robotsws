*** Settings ***
Documentation
...    Author: Natalia Grun (natalia.grun@nokia.com)
...    Maintainer: Natalia Grun (natalia.grun@nokia.com)
...    Group in charge: BTS_OAM_VERIF
...    References: doors
...    Feature Description: CB005750_5G_EB_ET_5GC000952
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET2/CB005750_5G_EB_ET_5GC000952/general.robot

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
5GC000952_ASIL_ABIO_Check_if_4th_Site_recovery_reset_within_1_hour_is_not_executed

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
        Restart Wts for OnAir
        ADMIN Wait Until BTS OnAir
        Wait Until Keyword Succeeds  100  20    ADMIN INFOMODEL Check if Cell is in availabilityStatus Online


5GC000952_ASIL_ABIO_Check_if_Site_recovery_reset_counter_is_incremented_and_if_BTS_reaches_onAir_after_Site_reset

        log to console   trigger fault 4383
        ${restartCounter_before}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-${BTS_Side}/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter

        Trigger 4383 and check increment counter
#        ADMIN Wait Until BTS OnAir
        ADMIN INFOMODEL Check if Cell is in availabilityStatus Online

#        ${mplaneResetReasonDetailed}    ADMIN INFOMODEL Get Parameter Value                    # or inactivate the flag  0x4F0214=0
#        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-${BTS_Side}/EQM_L-1/CABINET_L-1/SMOD_L-1           # ERadLteHas_BB_PERIPHERIES_EnableHwfLoading
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


5GC000952_ASIL_ABIO_Check_if_Site_recovery_reset_counter_is_cleared_and_Check_if_transient_alarm_is_reported_in_WebEM

        log to console   trigger fault 4383
        Trigger 4383 and check increment counter
        admin.ADMIN Reset Site
        Restart Wts for OnAir
        ADMIN Wait Until BTS OnAir
        ADMIN INFOMODEL Check if Cell is in availabilityStatus Online

        ${restartCounter_after}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-${BTS_Side}/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
        should be equal as integers   ${restartCounter_after}   0
        log to console    RestartCounter value: ${restartCounter_after} after SiteReset

        log to console   trigger fault 4383
        Trigger 4383 and check increment counter
#        ADMIN Wait Until BTS OnAir
        ADMIN INFOMODEL Check if Cell is in availabilityStatus Online
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


Trigger 4383 and check increment counter
        Check If BTS Is OnAir And Alarm Is Not Active   4383
        ${restartCounter_before}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-${BTS_Side}/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter

        Kill pmagent to trigger fault 4383
        ${status}    Run Keyword And Return Status
        ...        Wait Until Keyword Succeeds  250  0.3      ADMIN INFOMODEL Check Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/FRI-${BTS_Side}/RECOVERY_RESET_IND-1
        ...    dict_param=recoveryFaultID
        ...    value=4383
        IF    '${status}' == 'False'
        5GC000952.ADMIN Check If Alarm Is Active With Timeout    fault_id=4383    severity=Warning    timeout=20
        ELSE
        Run Keyword And Ignore Error    5GC000952.ADMIN Check If Alarm Is Active With Timeout    fault_id=4383    severity=Warning    timeout=20
        END

        Check If Recovery Action Is Performed
        Sleep  45s
        Wait Until Keyword Succeeds     120   5   ADMIN INFOMODEL Check if BBMOD is in availabilityStatus Offline
        Wait Until Keyword Succeeds     30   5    ADMIN INFOMODEL Check if RMOD is in availabilityStatus NotInstalled

        log to console   sleep 360
        Sleep   360
        SYSTEM Check if fault is not in active raw alarm  4383   EFaultId_VirtualNodeNotRespondingAl
        ADMIN Check If Alarm Is Not Active  fault_id=4383
        ADMIN INFOMODEL Check if BBMOD is in availabilityStatus Online
        Restart Wts for OnAir
        ADMIN INFOMODEL Check if RMOD is in availabilityStatus Online

        ${restartCounter_after}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-${BTS_Side}/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
        should be equal as integers   ${restartCounter_after}    ${${restartCounter_before}+1}
        log to console   restartCounter: ${restartCounter_after}

        Wait Until Keyword Succeeds     420    5     ADMIN INFOMODEL Check If BTS Is OnAir


Trigger 4383 for 4th time
        Check If BTS Is OnAir And Alarm Is Not Active   4383
        ${restartCounter_before}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-${BTS_Side}/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter

        Kill pmagent to trigger fault 4383
        Sleep   60
        SYSTEM Check if fault is in active raw alarm  4383   EFaultId_VirtualNodeNotRespondingAl
        5GC000952.ADMIN Check If Alarm Is Active With Timeout  fault_id=4383  severity=Critical   timeout=60

        ${restartCounter_after}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-${BTS_Side}/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
        should be equal   ${restartCounter_after}    ${restartCounter_before}

        ADMIN INFOMODEL Check if Cell is in availabilityStatus Failed


5GC000952_ASIL_ABIO_Check_if_4th_FSP_recovery_reset_within_1_hour_is_not_executed
#       log to console    Start 5GC000952_ASIL_ABIO_Check_if_4th_FSP_recovery_reset_within_1_hour_is_not_executed

       admin.ADMIN Perform Delta Recommissioning
        ...                 delta_file=${Delta_Set_actForceAutoReset_actForceUnitAutoReset_True}
        ...                 skip_parameter_relation_errors=True

       SYSTEM Add Flag In Swconfig File without Site Reset    0x500001=0      # ${SYSTEM_ALIAS_ASIL}
       ADMIN Reset Site
       Restart Wts for OnAir
       ADMIN Wait Until BTS OnAir
#       Trigger 4383 and check increment counter
#       Trigger 4383 and check increment counter
#       Trigger 4383 and check increment counter

       log to console   trigger fault 4019 for 4 times in an hour
       Run keyword and ignore error   Run   rm -f /tmp/syslog_recov_counter.log

       ${counter_value_before}=   Set variable   0
       FOR    ${INDEX}  IN RANGE    0   3
           log to console    ${${INDEX}+1} recovery action done
           ${counter_value_before}=   Trigger 4019 and check increment counter  ${counter_value_before}  # ${INDEX}
       END
        log to console    4 recovery action done
        Trigger 4019 for 4th time

        admin.ADMIN Reset Site
        Wait Until Keyword Succeeds     300   5    ADMIN INFOMODEL Check if BBMOD is in availabilityStatus Online
        Wait Until Keyword Succeeds     300   5    ADMIN INFOMODEL Check if RMOD is in availabilityStatus Online
        Restart Wts for OnAir

        ADMIN Wait Until BTS OnAir
        ADMIN INFOMODEL Check if Cell is in availabilityStatus Online
#       log to console    Stop 5GC000952_ASIL_ABIO_Check_if_4th_FSP_recovery_reset_within_1_hour_is_not_executed


5GC000952_ASIL_ABIO_Check_if_FSP_recovery_reset_counter_is_incremented_and_Check_if_transient_alarm_in_WebEM

        log to console   trigger fault 4019
        Trigger 4019 and check increment counter  0         # the argument: counter
        ADMIN INFOMODEL Check if Cell is in availabilityStatus Online

        ${restartCounter_after}    ADMIN INFOMODEL Get Parameter Value
        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-${BTS_Side}/EQM_L-1/CABINET_L-1/SMOD_L-1
        ...    dict_param=restartCounter
        log to console   restartCounter: ${restartCounter_after}

        admin.ADMIN Perform Delta Recommissioning
        ...                 delta_file=${Delta_Set_actForceAutoReset_actForceUnitAutoReset_False}
        ...                 skip_parameter_relation_errors=True


5GC000952_ASIL_ABIO_Check_if_FSP_recovery_reset_counter_is_cleared_after_1_hour_and_after_Site_reset
#        log to console    Start
#        ...     5GC000952_ASIL_ABIO_Check_if_FSP_recovery_reset_counter_is_cleared_after_1_hour_and_after_Site_reset

        SYSTEM Add Flag In Swconfig File without Site Reset    0x500001=0      # ${SYSTEM_ALIAS_ASIL}
        ADMIN Reset Site
        Restart Wts for OnAir
        ADMIN Wait Until BTS OnAir

        log to console   trigger fault 4019 - twice
        ${cnt}=   Trigger 4019 and check increment counter   0
        ${cnt1}=  Trigger 4019 and check increment counter   ${cnt}
        log to console    BBMOD Recovery reset counter value: ${cnt1} before SiteReset

        admin.ADMIN Reset Site
        Restart Wts for OnAir
        ADMIN Wait Until BTS OnAir
        Wait Until Keyword Succeeds  100  20  ADMIN INFOMODEL Check if Cell is in availabilityStatus Online

        log to console   trigger fault 4019 - twice
        ${cnt}=   Trigger 4019 and check increment counter   0
        log to console    BBMOD Recovery reset counter value: ${cnt} after SiteReset
        ${cnt1}=  Trigger 4019 and check increment counter   ${cnt}
        log to console    BBMOD Recovery reset counter value: ${cnt1} before wait for 1 hour
        ADMIN Wait Until BTS OnAir
        ADMIN INFOMODEL Check if Cell is in availabilityStatus Online

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


Trigger 4019 and check increment counter
        [Arguments]    ${counter_value_before}
        Check If BTS Is OnAir And Alarm Is Not Active    4019

#        Run keyword and ignore error   Run   rm -f /tmp/syslog_test_recov.log
#        Run keyword and ignore error   Run   cp /tmp/btslog2/SYSLOG*.LOG /tmp/syslog_test_recov.log
#        Run Keyword And ignore error   Run
#        ...         grep -irn "Reset counter for" /tmp/syslog_test_recov.log > /tmp/syslog_recov_counter.log
#        ${not_empty_file}=  Run Keyword And ignore error   File should not be empty   /tmp/syslog_recov_counter.log
#        ...                             "Empty file!"
##        ${counter_value_before}=   Set variable   0
#
#        Run keyword if   '${not_empty_file}[0]' == 'PASS'
#        ...    Run Keywords   ${file_content}=  OperatingSystem.Run  cat /tmp/syslog_recov_counter.log
#        ...    log to console    cat \${file_content}=${file_content}
#        ...    ${counter_value_split}=   Split string     ${file_content}    separator=\is:
#        ...    ${counter_value}=         Get from list         ${counter_value_split}     1
#        ...    ${value_before}=          Convert To String   ${counter_value}
#        log to console   value counter before: ${value_before}

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
        IF    '${status}' == 'False'
        5GC000952.ADMIN Check If Alarm Is Active With Timeout    fault_id=4019    severity=Warning    timeout=100
        ELSE
        Run Keyword And Ignore Error    5GC000952.ADMIN Check If Alarm Is Active With Timeout    fault_id=4019    severity=Warning    timeout=100
        END

        Wait Until Keyword Succeeds     120   5   ADMIN INFOMODEL Check if BBMOD is in availabilityStatus Offline
        Wait Until Keyword Succeeds     30   5    ADMIN INFOMODEL Check if RMOD is in availabilityStatus NotInstalled
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
#        Restart Wts for OnAir

        Wait Until Keyword Succeeds     120   5    ADMIN INFOMODEL Check if BBMOD is in availabilityStatus Online
        Wait Until Keyword Succeeds     350   5    ADMIN INFOMODEL Check if RMOD is in availabilityStatus Online

        ${counter_value_after}=   Get BBMOD recovery reset counter value from syslog
        IF    ${counter_value_after} > 0
        Should Be Equal As Integers    ${counter_value_after}    ${counter_value_before + 1}
        END

##        ${syslog_pid}=    taf.sbts.oam.coam.admin.Run Keyword In Background
#        ...                  name='/opt/ute/python/bin/cli_syslog.py -d /tmp -l enb_syslog.log'   #enb_get_syslog
        Restart Wts for OnAir
        Wait Until Keyword Succeeds     420    5     ADMIN INFOMODEL Check If BTS Is OnAir

        [Return]    ${counter_value_after}


Restart Wts for OnAir
        Reach onAir Teardown
        ute_wts_runner.Start UTE WTS
        X2 Connection

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


Trigger 4019 for 4th time
        Check If BTS Is OnAir And Alarm Is Not Active   4019

        Killall HWRTimeSExe to trigger fault 4019
        Sleep   60
        SYSTEM Check if fault is in active raw alarm  4019    EFaultId_KeepAliveStatusErrorAl
#                               EFaultId_VirtualNodeNotRespondingAl
#                                         Master unit has lost connection to the slave unit
        5GC000952.ADMIN Check If Alarm Is Active With Timeout  fault_id=4019  severity=Critical   timeout=360

        ADMIN INFOMODEL Check if Cell is in availabilityStatus Failed


#Kill pmagent to trigger fault 4383
#    ${process_pid}=   SYSTEM Execute Command On gNB
#    ...    command=ps aux | grep -i "pmagent" | egrep -v "grep|bash" | awk '{print $2}'
#    ...    alias=${SYSTEM_ALIAS_ASIL}
#    @{list_process_pid}=  split to lines  ${process_pid}
#    ${status}   Run Keyword And Return Status   SYSTEM Execute Command On gNB
#    ...    command=kill -11 @{list_process_pid}[0]
#    ...    alias=${SYSTEM_ALIAS_ASIL}
#    Run Keyword Unless   ${status}   SYSTEM Execute Command On gNB
#    ...                     systemctl stop hwr-container@TRACECM00.service

Kill pmagent to trigger fault 4383
#    SYSTEM Execute Command On gNB   systemctl stop hwr-container@FHNET00.service
     SYSTEM Execute Command On gNB   pkill -11 -f '/opt/CCS/ccs.ratstart 0x2018 0x2011'


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
    #...         ${severity}
    ...         ${connection}=${ADMIN_ALIAS}
    @{out_alarms_objects_list}    ADMIN Get Active Alarms   ${connection}
        FOR    ${alarm}    IN    @{out_alarms_objects_list}
        ${dict_fault_id}    Get From Dictionary    ${alarm}    faultId
        ${dict_severity}    Get From Dictionary    ${alarm}    severity
        ${dict_faultName}   Get From Dictionary    ${alarm}    faultName  #'BTS site autonomous reset as recovery action'

        IF    '${dict_fault_id}' == '${fault_id}'
                IF    '${dict_severity}' == '${severity}'
                Log To Console    Fault ${dict_fault_id} - ${dict_severity} - ${dict_faultName}
                RETURN    ${TRUE}
                END
        END
        END

    return from keyword    ${FALSE}

ADMIN Check If Alarm Is Active and severity
    [Arguments]    ${fault_id}
    #...            ${severity}
    ...            ${connection}=${ADMIN_ALIAS}
    ${is_active}    ADMIN Is alarm active and get severity  ${fault_id}   ${connection}
    Should Be True   ${is_active}

ADMIN Check If Alarm Is Active With Timeout
    [Arguments]    ${fault_id}
    ...            ${severity}
    ...            ${timeout}
    wait until keyword succeeds  ${timeout}  0.5  ADMIN Check If Alarm Is Active and severity   ${fault_id}  ${severity}


Verify if Alarm Managed Object for '${fault_id}' is not in Info Model
    ute_admin_infomodel.Query infomodel  query=count ${alarm_path} is [faultId=${fault_id}] = 0  timeout=60
