*** Settings ***
Documentation
...    Author: George Medesan (george.medesan@nokia.com)
...    Maintainer: George Medesan (george.medesan@nokia.com)
...    Group in charge: BTS_OAM_VERIF_ET1
...    References: doors
...    Feature Description:CB008313-5G-B_CB007422-5G
...    Sample execution: /opt/ute/python/bin/robot --variable CONFIGURATION:$UTE_CONFIGURATION -L TRACE -b debug.log
...    -d results/ /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB008313-5G-B_CB007422/general.robot

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library      taf.transport.ssh   WITH NAME   csn

Resource    ./keywords.robot
Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot


*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${asik_addr}                     192.168.255.1
${asik_username}                 toor4nsn
${asik_password}                 oZPS0POrRieRtu

${reasoning_path}=            /MRBTS-1/RAT-1/BTS_L-1/EQM_L-1/RMOD_L-1/RU_L-1

${scf_path}             /tmp/
${scf_name}             scf_file.xml

*** Keywords ***

CB008313-5G-B_CB007422-1_Fault_4592_triggering_with_actFaultSignature
    Log to console   Perform Reset Site
    admin.ADMIN Reset Site
    Check BTS Status is in Configured state after reset
    Check FaulID 4592

CB008313-5G-B_CB007422-2_Fault_4383_triggering_with_actFaultSignature
    log to console  Start test fault 4383
    Check not uncommissioned state
#    Wait Until Keyword Succeeds  60  10    ADMIN Check BTS onair
    SYSTEM Check if fault is not in active raw alarm  4383   EFaultId_VirtualNodeNotRespondingAl
    ADMIN Check If Alarm Is Not Active  fault_id=4383

#    Trigger Fault 4383 And Should Have Been Raised



    Trigger 4383 and check increment counter
    Wait Until Keyword Succeeds  300s  10s  Check If BTS Is Not In Uncommissioned State
    Wait Until Keyword Succeeds  300s  10s  Check if RMOD is in availabilityStatus Online
#   ADMIN Wait Until BTS OnAir
#   Check if Cell is in availabilityStatus Online
#    ADMIN Check BTS Configured

    Sleep  60
    SYSTEM Check if fault is not in active raw alarm  4383   EFaultId_VirtualNodeNotRespondingAl
    ADMIN Check If Alarm Is Not Active  fault_id=4383
    Check not uncommissioned state

#    Wait Until Keyword Succeeds  300  20    ADMIN Check BTS onair

#    Check FaulID 4383 is not present
#    Stop container to trigger fault 4383
#    Check FaulID 4383 is present
#    Check BTS Status is in Configured state after reset


Check BTS Status is in Configured state after reset
    Sleep  30
    SYSTEM Wait Till Gnb Will Be Pingable For A Given Period
    wait until keyword succeeds  900s  10s   Check If BTS Configured

Check FaulID 4592
    wait until keyword succeeds  1300s  30s    ADMIN Check If Alarm Is Active  fault_id=4592
    Log to console   Fault 4592 is visible

Check FaulID 4383 is not present
    ADMIN Check If Alarm Is Not Active  fault_id=4383
    Log to console   Fault 4383 is not visible

Check FaulID 4383 is present
    wait until keyword succeeds  60     0.001    ADMIN Check If Alarm Is Active  fault_id=4383
    Log to console   Fault 4383 is visible

#Stop container to trigger fault 4383
#    SYSTEM Execute Command On gNB
##     ...    command=systemctl stop hwr-container@TRACECM00.service
#     ...    command=lxc-ls --active
#     ...    command=lxc-attach -n 0x1018
#     ...    command=ps aux
#     ...    command=kill -9 -1
#     Log to console   Fault 4383 trigger command

Check If BTS Configured
    ${bts_statuses_response}=    taf.gnb.oam.coam.admin.Get Bts Info
    ${actual_value}=    Get From Dictionary
    ...    dictionary=${bts_statuses_response['status']}
    ...    key=proceduralState
    Should Be Equal
    ...    first=${actual_value}
    ...    second=Configured

Test Preconditions for CB008313
    Test Preconditions
    Log to console  actFaultSignature=True
    taf.gnb.oam.coam.admin.perform_parameter_recommissioning
    ...                                  dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                  parameter=actFaultSignature
    ...                                  value=true
    ...                                  operation=update
    ...                                  skip_parameter_relation_errors=True

Test Postconditions for CB008313
    Test Postconditions
    Log to console  actFaultSignature=False
    taf.gnb.oam.coam.admin.perform_parameter_recommissioning
    ...                                  dist_name=MRBTS-${OUT_MRBTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ...                                  parameter=actFaultSignature
    ...                                  value=false
    ...                                  operation=update
    ...                                  skip_parameter_relation_errors=True

Trigger 4383 and check increment counter
        Check If BTS Is OnAir And Alarm 4383 Is Not Active
#        Check If BTS Is Configured And Alarm Is Not Active    4383
#        ${restartCounter_before}    ADMIN INFOMODEL Get Parameter Value
#        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-${BTS_Side}/EQM_L-1/CABINET_L-1/SMOD_L-1
#        ...    dict_param=restartCounter

#        Kill pmagent to trigger fault 4383
#        Stop container to trigger fault 4383
        Kill CCSDaemonExe process to trigger fault 4383
#        ${status}    Run Keyword And Return Status
#        ...        Wait Until Keyword Succeeds  110  0.3      ADMIN INFOMODEL Check Parameter Value
#        ...    dist_name=/MRBTS-1/RAT-1/FRI-1/RECOVERY_RESET_IND-1
#        ...    dict_param=recoveryFaultID
#        ...    value=4383

        CB007422-5G.ADMIN Check If Alarm Is Active With Timeout  fault_id=4383  severity=Warning   timeout=180

#        Run keyword if   '${status}'=='False'
#        ...         CB007422-5G.ADMIN Check If Alarm Is Active With Timeout  fault_id=4383  severity=Warning   timeout=180
#        ...    ELSE   run keyword and ignore error
#        ...         CB007422-5G.ADMIN Check If Alarm Is Active With Timeout  fault_id=4383  severity=Warning   timeout=180

#        Check If Recovery Action Is Performed
        Sleep  45s
#        Check if BBMOD is in availabilityStatus Offline
#        Wait Until Keyword Succeeds     600s  5s  Check if RMOD is in availabilityStatus NotInstalled
        Wait Until Keyword Succeeds     720s  10s  Check if RMOD is in availabilityStatus Online

        log to console   Wait until BTS is OnAir
        Restart Wts for OnAir
        Wait Until Keyword Succeeds     900    5     ADMIN INFOMODEL Check If BTS Is OnAir
#        ADMIN Check BTS Configured

        SYSTEM Check if fault is not in active raw alarm  4383   EFaultId_VirtualNodeNotRespondingAl
        ADMIN Check If Alarm Is Not Active  fault_id=4383
#        Check if BBMOD is in availabilityStatus Online
#        Check if SMOD is in availabilityStatus Online
#        Check if RMOD is in availabilityStatus Online

#        ${restartCounter_after}    ADMIN INFOMODEL Get Parameter Value
#        ...    dist_name=/MRBTS-1/RAT-1/BTS_L-${BTS_Side}/EQM_L-1/CABINET_L-1/SMOD_L-1
#        ...    dict_param=restartCounter
#        should be equal as integers   ${restartCounter_after}    ${${restartCounter_before}+1}
#        log to console   restartCounter: ${restartCounter_after}



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

Check if RMOD is in availabilityStatus Online
    #[Arguments]      ${timeout}=30s
    ${status}  Run Keyword And Return Status   ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...      value=Online
    Run Keyword Unless  ${status}  ADMIN INFOMODEL Check AvailabilityStatus Value
    ...      dist_name=/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/RMOD_R-1
    ...      value=none


ADMIN Check If Alarm Is Active With Timeout
    [Arguments]    ${fault_id}
    ...            ${severity}
    ...            ${timeout}
    wait until keyword succeeds  ${timeout}  0.1  ADMIN Check If Alarm Is Active and severity   ${fault_id}  ${severity}

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

        IF    '${dict_fault_id}' == '${fault_id}' and '${dict_severity}' == '${severity}'
            Log To Console   Fault ${dict_fault_id} - ${dict_severity} - ${dict_faultName}
            Return From Keyword    ${TRUE}
        END
    END
    return from keyword    ${FALSE}

ADMIN Check If Alarm Is Active and severity
    [Arguments]    ${fault_id}
    ...            ${severity}
    ...            ${connection}=${ADMIN_ALIAS}
    ${is_active}    ADMIN Is alarm active and get severity  ${fault_id}   ${severity}   ${connection}
    Should Be True   ${is_active}


Verify if Alarm Managed Object for '${fault_id}' is not in Info Model
    ute_admin_infomodel.Query infomodel  query=count ${alarm_path} is [faultId=${fault_id}] = 0  timeout=60
