*** Settings ***
Documentation
...   contact: I_5G_SISO_CRT_GMS <I_5G_SISO_CRT@internal.nsn.com>

Library     ../../../../../resources/python_libs/verify_rf.py
Library     taf.sbts.oam.coam.admin             WITH NAME  admin
Library     taf.ul.alarms_watchdog             WITH NAME  watchdog
Library     PythonKeywords/alarms.py        WITH NAME  alarms
Library     PythonKeywords/tl_topology.py        WITH NAME  tl_topology
#Library     testsuite/OAM/Wroclaw/cOAM1/CommonKeywords/PythonKeywords/alarms.py
Library     Collections
Library     DateTime

*** Keywords ***
Admin Check IF Unexpected Alarms Exist
    [Documentation]  DEPRECATED
    [Arguments]  ${mandatory_alarms_list}=${empty}   ${alowed_alarms_list}=${empty}  ${connection}=admin    ${timeout}=30
    ${active_alarms_list}=   Alarms_OAM.Admin Get Active Alarms cOAM1  connection=${connection}   timeout=${timeout}
    ${active_alarms_not_alowed}=    Remove Alowed Alarms From Active Alarm List cOAM1
    ...    active_alarms_list=${active_alarms_list}  alowed_alarms_list=${alowed_alarms_list}
    ${unexpected_alarms_list}=    Admin Remove Mandatory Alarms From Active Alarm List cOAM1
    ...    active_alarms_list=${active_alarms_not_alowed}   mandatory_alarms_list=${mandatory_alarms_list}
    Should Not Be True  ${unexpected_alarms_list}    !!! Unexpected alarm exist !!!${unexpected_alarms_list}

Admin Remove Mandatory Alarms From Active Alarm List cOAM1
    [Arguments]  ${active_alarms_list}=none  ${mandatory_alarms_list}=none
    ${active_alarms_number}=   Get Length  ${active_alarms_list}
    ${not_alowed_alarms_list}=   Create List
    FOR  ${alarm_no}  IN RANGE  ${active_alarms_number}
        ${checked_alarm_detail}=  Set Variable    ${active_alarms_list[${alarm_no}]["alarmDetail"]}
        ${not_on_list}=  Run Keyword And Return Status
        ...  Check If Alarm Alowed cOAM1   alowed_alarms_list=${mandatory_alarms_list}   checked_alarm=${checked_alarm_detail}
        ${alarm}=   Get From List  ${active_alarms_list}   ${alarm_no}
        Run Keyword If  ${not_on_list}   Append To List  ${not_alowed_alarms_list}   ${alarm}
    END
    [Return]    ${not_alowed_alarms_list}

Check If Mandatory Alarm Exist cOAM1
    [Documentation]  DEPRECATED
    [Arguments]    ${faultId}=none    ${alarmDetail}=none  ${alarmSeverity}=none   ${faultNr}=1   ${connection}=admin
    ${active_alarms_list}=   Admin Get Active Alarms cOAM1  connection=${connection}
    ${active_alarms_number}=   Get Length  ${active_alarms_list}
    @{list_of_mandatory_alarm_index}=    Create List
    FOR  ${index}  IN RANGE  ${active_alarms_number}
        ${exist}=   Run Keyword And Return Status   dictionary should contain item  ${active_alarms_list[${index}]}   faultId    ${faultId}
        Run Keyword If   ${exist}  Append To List  ${list_of_mandatory_alarm_index}  ${index}
    END
    Should Be True  ${list_of_mandatory_alarm_index}      ! Mandatory alarm does not exist !
    ${number_of_mandatory_alarm}=    Get Length  ${list_of_mandatory_alarm_index}
    Should Be True  ${number_of_mandatory_alarm} == ${faultNr}     ! Number of mandatory alarms is different than expected !
    Dictionary Should Contain Item  ${active_alarms_list[${list_of_mandatory_alarm_index[0]}]}    faultId    ${faultId}
    Dictionary Should Contain Item  ${active_alarms_list[${list_of_mandatory_alarm_index[0]}]}    alarmDetail    ${alarmDetail}
    Dictionary Should Contain Item  ${active_alarms_list[${list_of_mandatory_alarm_index[0]}]}    severity     ${alarmSeverity}

Remove Mandatory Alarms From Active Alarm List
    [Documentation]  DEPRECATED
    [Arguments]  ${active_alarms_list}=none  ${mandatory_alarms_list}=none
    ${active_alarms_number}=   Get Length  ${active_alarms_list}
    ${not_alowed_alarms_list}=   Create List
    FOR  ${alarm_no}  IN RANGE  ${active_alarms_number}
        ${checked_alarm_detail}=  Set Variable    ${active_alarms_list[${alarm_no}]["additionalText1"]}
        ${not_on_list}=  Run Keyword And Return Status
        ...  Check If Alarm Alowed cOAM1  alowed_alarms_list=${mandatory_alarms_list}   checked_alarm=${checked_alarm_detail}
        ${alarm}=   Get From List  ${active_alarms_list}   ${alarm_no}
        Run Keyword If  ${not_on_list}   Append To List  ${not_alowed_alarms_list}   ${alarm}
    END
    [Return]    ${not_alowed_alarms_list}

Check Unexpected Alarms
    [Documentation]  DEPRECATED
    [Arguments]    ${alowed_alarms_list}=none    ${connection}=admin
    ${active_alarms_list}=   Admin Get Active Alarms cOAM1  connection=${connection}
    ${unexpected_alarms_list}=  Remove Alowed Alarms From Active Alarm List cOAM1
    ...    active_alarms_list=${active_alarms_list}  alowed_alarms_list=${alowed_alarms_list}
    Should Not Be True  ${unexpected_alarms_list}    !!! Unexpected alarm exist !!!${unexpected_alarms_list}
    [Return]  ${unexpected_alarms_list}

Admin Get Active Alarms cOAM1
    [Arguments]    ${connection}=admin    ${timeout}=10
    #${active_alarms_number}  admin.get_active_alarms_number   connection=${connection}   timeout=${timeout}
    ${active_alarms_list}    admin.get_active_alarms   connection=${connection}   timeout=${timeout}
    [Return]    ${active_alarms_list}

Remove Alowed Alarms From Active Alarm List cOAM1
    [Arguments]  ${active_alarms_list}=none  ${alowed_alarms_list}=none
    ${active_alarms_number}=   Get Length  ${active_alarms_list}
    ${not_alowed_alarms_list}=   Create List
    FOR  ${alarm_no}  IN RANGE  ${active_alarms_number}
        ${checked_alarm_detail}=  Set Variable    ${active_alarms_list[${alarm_no}]["alarmDetail"]}
        ${not_on_list}=  Run Keyword And Return Status
        ...  Check If Alarm Alowed cOAM1  alowed_alarms_list=${alowed_alarms_list}   checked_alarm=${checked_alarm_detail}
        ${alarm}=   Get From List  ${active_alarms_list}   ${alarm_no}
        Run Keyword If  ${not_on_list}   Append To List  ${not_alowed_alarms_list}   ${alarm}
    END
    [Return]    ${not_alowed_alarms_list}

Check If Alarm Alowed cOAM1
    [Arguments]  ${alowed_alarms_list}=none  ${checked_alarm}=none
    FOR  ${alarm}  IN  @{alowed_alarms_list}
       Should Not Match Regexp  ${checked_alarm}   ${alarm}
    END

Start alarms watchdog
    [Arguments]  ${interval}=2 sec
    Log to console         Starting alarms watchdog
    ${tl_topology}=        tl_topology.Get test line topology
    ...                    cloud_topology=${tl.tl_cloud_topology}
    ${allowed_alarms}=     alarms.get_default_allowed_alarms
    watchdog.watch_alarms  allowed_alarms=${allowed_alarms}
    ...                    interval=${interval}
    ...                    bts_config=${tl.gnbs[0]}

Check alarms and stop watchdog cOAM1
    [Arguments]  ${reset_allowed_alarms}=${True}
    Log to console                           Checking alarms and stopping watchdog
    ${default_allowed_alarms}=               alarms.get_default_allowed_alarms
    Run keyword if  ${reset_allowed_alarms}  watchdog.disallow_all_alarms_except_of
    ...                                      alarms=${default_allowed_alarms}
    watchdog.check_detected_alarms
    [Teardown]  watchdog.stop_watching_alarms

Check if X2 link is down by active alarms
    watchdog.is_alarm_active  fault_id=7300
    ...                       fault_name=No X2 link available
    watchdog.is_alarm_active  fault_id=7319
    ...                       fault_name=No X2 link available for a specific LTEENB

Allow alarm in watchdog
    [Arguments]    ${alarm}
    watchdog.allow_alarm    fault_name=${alarm}

Disallow alarm in watchdog
    [Arguments]    ${alarm}
    watchdog.disallow_alarm    fault_name=${alarm}

Disable alarm reporting during reset
    Disallow alarm in watchdog    No X2 link available
    Disallow alarm in watchdog    No X2 link available for a specific LTEENB

Enable alarm reporting after reset
    Allow alarm in watchdog    No X2 link available
    Allow alarm in watchdog    No X2 link available for a specific LTEENB


Check if the number of alarms is equal to the number of RU cOAM1
    [Documentation]  DEPRECATED
    [Arguments]  ${number_of_radio_units}
    ...          ${alarm_id}
    ${number_of_fault}  number_of_specific_active_faults_cOAM1   alarm_id=${alarm_id}   connection=admin
    should be equal as numbers    ${number_of_fault}       ${number_of_radio_units}
