*** Settings ***
Documentation
...    author:     Patryk Tatarek
...    contact:    patryk.tatarek@nokia.com

*** Variables ***
${falseIP}=                  10.42.100.100
${default_localPriority}=    128
${gnss_type}=                1pps/ToD from external GNSS receiver
${topp_type}=                TOPP

*** Keywords ***
Lose Synchronization with TOPP
    [Documentation]                    Lose synchronization with TOPP
    ...                                Output: masterIpAddr for TOPP (useful when you want to regain sync)
    ${correctIP_list}=                 Check current parameter value    param_name=masterIpAddr
    ...                                dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ${correctIP}=                      Get From List    ${correctIP_list}    ${0}
    ${values_dict}=                    Create Dictionary
    Set to Dictionary                  ${values_dict}    localPriority                ${default_localPriority}
    ...                                                  masterIpAddr                 ${falseIP}
    ...                                                  maximumNetworkTimingError    ${0}
    ...                                                  phaseErrorComp               ${0}
    ...                                                  topMasterId                  ${1}
    ${values_list}=                    Create List       ${values_dict}
    Change Parameter on BTS            dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ...                                param_name=topMasterList
    ...                                param_value=${values_list}
    ...                                skip_parameter_relation_errors=${True}
    Wait Until Alarm Appears On BTS    fault_id=4298
    [Return]                           ${correctIP}

Regaine Synchronization with TOPP
    [Documentation]                Regaine synchronization with TOPP
    ...                            Input: masterIpAddr for TOPP (output from "Lose Synchronization with TOPP" keyword)
    [Arguments]                    ${correctIP}
    ${values_dict}=                Create Dictionary
    Set to Dictionary              ${values_dict}    localPriority                ${default_localPriority}
    ...                                              masterIpAddr                 ${correctIP}
    ...                                              maximumNetworkTimingError    ${0}
    ...                                              phaseErrorComp               ${0}
    ...                                              topMasterId                  ${1}
    ${values_list}=                Create List       ${values_dict}
    Change Parameter on BTS        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ...                            param_name=topMasterList
    ...                            param_value=${values_list}
    ...                            skip_parameter_relation_errors=${True}
    Wait Until Keyword Succeeds    10min    10s    Alarm Should Not Be Active in BTS    fault_id=4298
    Wait Until Keyword Succeeds    10min    10s    Alarm Should Not Be Active in BTS    fault_id=6280

Lose Synchronization with GNSS
    [Documentation]                    Lose synchronization with GNSS
    ${temp_conn}=                      Connect to ADMIN
    Delete Parameter From BTS          dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...                                param_name=syncInputList
    ...                                skip_parameter_relation_errors=${True}
    ...                                connection=${temp_conn}
    Wait Until Keyword Succeeds        15min    60s    Wait until BTS reach Configured or OnAir state
    Wait Until Alarm Appears On BTS    fault_id=4405
    [Teardown]    Run Keyword and Ignore Error    Disconnect from ADMIN    ${temp_conn}

Regaine Synchronization with GNSS
    [Documentation]                Regaine synchronization with GNSS
    ${values_dict}=                Create Dictionary
    Set to Dictionary              ${values_dict}    syncInputPrio    ${1}
    ...                                              syncInputType    ${gnss_type}
    ${values_list}=                Create List       ${values_dict}
    Change Parameter on BTS        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...                            param_name=syncInputList
    ...                            param_value=${values_list}
    ...                            skip_parameter_relation_errors=${True}
    Wait Until Keyword Succeeds    15min    60s    Wait until BTS reach Configured or OnAir state
    Wait Until Keyword Succeeds    15min    10s    Alarm Should Not Be Active in BTS    fault_id=4405
    Wait Until Keyword Succeeds    10min    10s    Alarm Should Not Be Active in BTS    fault_id=6280

Regaine Synchronization with GNSS and TOPP
    [Documentation]                Regaine synchronization with both GNSS (as first prio) and TOPP (as second prio)
    ...                            Input: masterIpAddr for TOPP (output from "Lose Synchronization with TOPP" keyword)
    [Arguments]                    ${correctIP}
    ${values_dict1}=               Create Dictionary
    ${values_dict2}=               Create Dictionary
    Set to Dictionary              ${values_dict1}    syncInputPrio    ${1}
    ...                                               syncInputType    ${gnss_type}
    Set to Dictionary              ${values_dict2}    syncInputPrio    ${2}
    ...                                               syncInputType    ${topp_type}
    ${values_list}=                Create List       ${values_dict1}    ${values_dict2}
    Change Parameter on BTS        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1
    ...                            param_name=syncInputList
    ...                            param_value=${values_list}
    ...                            skip_parameter_relation_errors=${True}
    Wait Until Keyword Succeeds    15min    60s    Wait until BTS reach Configured or OnAir state
    ${values_dict}=                Create Dictionary
    Set to Dictionary              ${values_dict}    localPriority                ${default_localPriority}
    ...                                              masterIpAddr                 ${correctIP}
    ...                                              maximumNetworkTimingError    ${0}
    ...                                              phaseErrorComp               ${0}
    ...                                              topMasterId                  ${1}
    ${values_list_topp}=           Create List       ${values_dict}
    Change Parameter on BTS        dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/TOP-1/TOPP-1
    ...                            param_name=topMasterList
    ...                            param_value=${values_list_topp}
    ...                            skip_parameter_relation_errors=${True}
    Wait Until Keyword Succeeds    15min    10s    Alarm Should Not Be Active in BTS    fault_id=4405
    Wait Until Keyword Succeeds    10min    10s    Alarm Should Not Be Active in BTS    fault_id=4298
    Wait Until Keyword Succeeds    10min    10s    Alarm Should Not Be Active in BTS    fault_id=6280

Disconnect from All CNUM Sessions
    FOR    ${nr}    IN RANGE    1    ${stress_conns}
        Disconnect from ADMIN    admin${nr}
        Disconnect from ADMIN    read${nr}
    END

Disconnect from All CNUM System Admin Sessions
    FOR    ${nr}    IN RANGE    1    ${stress_conns}
        Disconnect from ADMIN    admin${nr}
    END

Disconnect from All CNUM Read Only Sessions
    FOR    ${nr}    IN RANGE    1    ${stress_conns}
        Disconnect from ADMIN    read${nr}
    END

Stress parameters change
    [Documentation]    Perform parameters related keywords in loop. Meant for System Admin or Security Admin.
    ...                Input:    state_before = state of BTS before test starts
    ...                          alarms_before = list of active alarms before test starts
    [Arguments]        ${state_before}    ${alarms_before}
    FOR    ${nr}    IN RANGE    1    ${stress_conns}
        Change Multiple Parameters on BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
        ...                                  localUserAllowedLifetime=50
        ...                                  localUserAllowedIdlePeriod=50
        ...                                  connection=admin${nr}
        ${localUserLifetime}=    Check current parameter value    param_name=localUserLifetimeExpDate
        ...                                                       connection=admin${nr}
        ${secAdmIdlePer}=        Check current parameter value    param_name=secAdmIdlePerExpDate
        ...                                                       connection=admin${nr}
        ${appAdmIdlePer}=        Check current parameter value    param_name=appAdmIdlePerExpDate
        ...                                                       connection=admin${nr}
        ${readOnlyIdlePer}=      Check current parameter value    param_name=readOnlyIdlePerExpDate
        ...                                                       connection=admin${nr}
        ${currentDate}=          Get Current Date
        ${currentDateUTC}=       Subtract Time From Date    ${currentDate}         2h
        ${expectedDate_plus}=    Add Time to Date        date=${currentDateUTC}    time=51 days
        ${expectedDate}=         Fetch From Left         ${expectedDate_plus}      ${SPACE}
        Should Contain           ${localUserLifetime}    ${expectedDate}
        Should Contain           ${secAdmIdlePer}        ${expectedDate}
        Should Contain           ${appAdmIdlePer}        ${expectedDate}
        Should Contain           ${readOnlyIdlePer}      ${expectedDate}
        Delete Parameter From BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
        ...                          param_name=localUserAllowedLifetime
        ...                          connection=admin${nr}
        Delete Parameter From BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
        ...                          param_name=localUserAllowedIdlePeriod
        ...                          connection=admin${nr}
        ${localUserLifetime}=    Check current parameter value    param_name=localUserLifetimeExpDate
        ...                                                       connection=admin${nr}
        ${secAdmIdlePer}=        Check current parameter value    param_name=secAdmIdlePerExpDate
        ...                                                       connection=admin${nr}
        ${appAdmIdlePer}=        Check current parameter value    param_name=appAdmIdlePerExpDate
        ...                                                       connection=admin${nr}
        ${readOnlyIdlePer}=      Check current parameter value    param_name=readOnlyIdlePerExpDate
        ...                                                       connection=admin${nr}
        Should be Empty     ${localUserLifetime}
        Should be Empty     ${secAdmIdlePer}
        Should be Empty     ${appAdmIdlePer}
        Should be Empty     ${readOnlyIdlePer}
        ${state_after}=     Wait Until Keyword Succeeds    1min    10s    Get current BTS state    connection=admin${nr}
        Should be Equal     ${state_before}    ${state_after}
        ${after}=           Get Active Alarms From BTS    connection=admin${nr}
        ${alarms_after}=    Sort List    ${after}
        Should be Equal     ${alarms_before}    ${alarms_after}
    END

Stress false parameters change
    [Documentation]    Perform parameters related keywords in loop. Meant for Application Admin and Read Only user.
    ...                Input:    state_before = state of BTS before test starts
    ...                          alarms_before = list of active alarms before test starts
    [Arguments]        ${state_before}    ${alarms_before}
    FOR    ${nr}    IN RANGE    1    ${stress_conns}
        Run Keyword and Expect Error    *    Change Multiple Parameters on BTS
        ...                                  dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
        ...                                  localUserAllowedLifetime=50
        ...                                  localUserAllowedIdlePeriod=50
        ...                                  connection=read${nr}
        Run Keyword and Expect Error    *    Change Parameter on BTS
        ...                                  dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
        ...                                  param_name=localUserAllowedLifetime
        ...                                  param_value=50
        ...                                  connection=read${nr}
        Run Keyword and Expect Error    *    Change Parameter on BTS
        ...                                  dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
        ...                                  param_name=localUserAllowedIdlePeriod
        ...                                  param_value=50
        ...                                  connection=read${nr}
        ${state_after}=     Wait Until Keyword Succeeds    1min    10s    Get current BTS state    connection=read${nr}
        Should be Equal     ${state_before}    ${state_after}
        ${after}=           Get Active Alarms From BTS    connection=read${nr}
        ${alarms_after}=    Sort List    ${after}
        Should be Equal     ${alarms_before}    ${alarms_after}
    END

Create CMD object
    ${conn}=      Connect to ADMIN
    Create Multiple Parameters on BTS      dist_name=MRBTS-${BTS_ID}/MNL-1/CMD-1
    ...                                    cmdId=${1}    connection=${conn}
    [Teardown]    Disconnect from ADMIN    ${conn}

Get Date from EMSsim Output
    [Documentation]    Take out date from raw EMSsim output
    [Arguments]        ${raw_output}
    ${raw_dict}=       Get From List    ${raw_output}    ${0}
    ${raw_list}=       Get Dictionary Values    ${raw_dict}
    ${raw_dict}=       Get From List    ${raw_list}    ${0}
    ${raw_list}=       Get Dictionary Values    ${raw_dict}
    ${raw_dict}=       Get From List    ${raw_list}    ${0}
    ${raw_list}=       Get Dictionary Values    ${raw_dict}
    ${date}=           Get From List    ${raw_list}    ${0}
    [Return]           ${date}

Delete Allowed parameters
    ${temp_conn}=                   Connect to ADMIN
    Delete Parameter From BTS       dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                             param_name=sysAdmAllowedLifetime
    ...                             connection=${temp_conn}
    Delete Parameter From BTS       dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                             param_name=sysAdmAllowedIdlePeriod
    ...                             connection=${temp_conn}
    Delete Parameter From BTS       dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                             param_name=localUserAllowedLifetime
    ...                             connection=${temp_conn}
    Delete Parameter From BTS       dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                             param_name=localUserAllowedIdlePeriod
    ...                             connection=${temp_conn}
    [Teardown]                      Disconnect from ADMIN    ${temp_conn}

Delete localUserAllowed parameters
    ${temp_conn}=                   Connect to ADMIN
    Delete Parameter From BTS       dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                             param_name=localUserAllowedLifetime
    ...                             connection=${temp_conn}
    Delete Parameter From BTS       dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                             param_name=localUserAllowedIdlePeriod
    ...                             connection=${temp_conn}
    [Teardown]                      Disconnect from ADMIN    ${temp_conn}

Delete LUACREQ in Teardown
    ${temp_conn}=             Connect to ADMIN
    Delete Object From BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/CMD-1/LUACREQ-1    connection=${temp_conn}
    [Teardown]    Disconnect from ADMIN    ${temp_conn}

Turn off actRestrictLoginToCnum
    ${temp_conn}=              Connect to ADMIN
    Change Parameter On BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1
    ...                        param_name=actRestrictLoginToCnum
    ...                        param_value=false
    ...                        connection=${temp_conn}
    [Teardown]    Disconnect from ADMIN    ${temp_conn}

Turn off autoCBRSCertDelete
    ${temp_conn}=              Connect to ADMIN
    Change Parameter On BTS    dist_name=MRBTS-${BTS_ID}/MNL-1/CERTH-1
    ...                        param_name=autoCBRSCertDelete
    ...                        param_value=false
    ...                        connection=${temp_conn}
    [Teardown]    Disconnect from ADMIN    ${temp_conn}

Collect Snapshot to Clear Alarms
    ${temp_conn}=              Connect To Admin
    coam_admin.get_snapshot    target_file_name=${CURDIR}/clearing_snapshot.zip
    ...                        coverage=Full
    ...                        timeout=1200
    ...                        connection=${temp_conn}
    Run                        rm ${CURDIR}/clearing_snapshot.zip
    [Teardown]    Disconnect From Admin    ${temp_conn}

Create LUACREQ via EMSsim
    [Arguments]    ${emssim_connection}
    execute_command_on_emssim_and_return_output    command=plan_create
    ...                                            connection=${emssim_connection}
    Sleep    3                                     reason=Executing command
    execute_command_on_emssim_and_return_output    command=plan_add MRBTS-${BTS_ID}/MNL-1/CMD-1/LUACREQ-1 -mandatory
    ...                                            connection=${emssim_connection}
    Sleep    3                                     reason=Executing command
    execute_command_on_emssim_and_return_output    command=plan_send -activate
    ...                                            connection=${emssim_connection}
    Sleep    90                                    reason=Executing command
    [Teardown]    Run Keywords                     Run Keyword and Ignore Error
    ...                                            execute_command_on_emssim
    ...                                            command=plan_destroy
    ...                                            connection=${emssim_connection}
    ...    AND                                     Sleep    3    reason=Executing command
