*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${REPEAT_TIME}    10
${ALARMS_BEFORE_TEST}    ${EMPTY}
${ALALRMS_AFTER_TEST}    ${EMPTY}
${REPEAT_TESTING_FAIL}    False
@{IGNORE_ALARM_FILTER_STRING}    {'faultId':61649}    {'faultId':61074}    {'faultId':4639}    {'faultId':4459}    {'faultId':8000}
${SKIP_PARAM_RELATION_ERRORS}    True

*** Keywords ***
CM__Repeat_5G_RAT_Lock_Unlock_via_AdminAPI
    [Documentation]    [CASE MRT]: RAN_SyVe_CM_Repeat_5G_RAT_Lock_Unlock_via_WebEM
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    Repeat to Lock/Unlock the 5G RAT by delta commission: Change NRDU administrativeState to
    ...    Locked/Unlocked through ADMIN API
    ...
    ...    The main steps performed for the test are:
    ...    . Repeat Lock Unlock 5G RAT
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 21.12.2021 - Kang Lixin - New case
    Set Tags    CM    AUTHOR-lixin.kang@nokia-sbell.com     OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Repeat Lock Unlock 5G RAT

Step ${index}: Repeat Lock Unlock 5G RAT
    ${REPEAT_TIME}    Evaluate    int(${REPEAT_TIME})
    ${failed_loops}    Create List
    FOR    ${index}    IN RANGE    1    ${REPEAT_TIME+1}
        Restart Infomodel And Syslog
        Set Test Variable    ${current_loop_index}    ${index}
        ${lock_oper_status}    Run Keyword And Return Status    Lock 5G RAT From Admin
        Run Keyword If    not ${lock_oper_status}    Run Keywords    Log    Lock 5G RAT Failed at Loop${current_loop_index}
        ...    console=${True}    level=ERROR
        ...    AND    Append To List    ${failed_loops}    ${current_loop_index}
        ...    AND    LoopTearDown
        ...    AND    Set Test Variable    ${REPEAT_TESTING_FAIL}    True
        ...    AND    Continue For Loop
        ${unlock_oper_status}    Run Keyword And Return Status    Unlock 5G RAT From Admin
        Run Keyword If    not ${unlock_oper_status}    Run Keywords    Log    Unlock 5G RAT Failed at Loop${current_loop_index}
        ...    console=${True}    level=ERROR
        ...    AND    Append To List    ${failed_loops}    ${current_loop_index}
        ...    AND    LoopTearDown
        ...    AND    Set Test Variable    ${REPEAT_TESTING_FAIL}    True
        ...    AND    Continue For Loop
    END
    Run Keyword If    ${REPEAT_TESTING_FAIL}    Fail    Repeat Lock Unlock 5G RAT failed at loop @{failed_loops}!

Lock 5G RAT From Admin
    Log To Console    Lock 5G RAT From Admin
    Set administrativeState Value To ${_Com_Locked_} via Delta Recommission For ${NRDU_DN}
    coam.Assert Every    NRCEL
    ...    administrativeState=${_Com_Unlocked_}, operationalState=${_Disabled_}, blockingState=${_Unblocked_}, availabilityStatus=${_Dependency_}
    ...    timeout=60
    Sleep    15s
    ${current_btsInfo}    coam.Get Bts Info
    Should Be Equal As Strings     ${current_btsInfo['ratState']['nr']}    ALL_DISABLED
    Should Be Equal As Strings     ${current_btsInfo['nrDU'][0]['status']['administrativeState']}    Locked
    Check Other RAT Status
    ${active_alarm}  coam.Get Alarms  alias=default
    Set Test Variable    ${ALARMS_AFTER_TEST}    ${active_alarm}
    ${alarms_cleared}    ${alarms_raised}    Compare Alarm List    ${ALARMS_BEFORE_TEST}    ${ALARMS_AFTER_TEST}    ${IGNORE_ALARM_FILTER}
    ${count}    Get Length    ${alarms_raised}
    Should Be Equal As Integers    ${count}    ${0}

Unlock 5G RAT From Admin
    Log To Console    Unlock 5G RAT From Admin
    Set administrativeState Value To ${_Com_Unlocked_} via Delta Recommission For ${NRDU_DN}
    coam.Assert Every    NRCEL    ${cells_NR_expected_state}    timeout=60
    Sleep    15s
    ${current_btsInfo}    coam.Get Bts Info
    Should Be Equal As Strings     ${current_btsInfo['ratState']['nr']}    ALL_ENABLED
    Should Be Equal As Strings     ${current_btsInfo['nrDU'][0]['status']['administrativeState']}    Unlocked
    Check Other RAT Status
    ${active_alarm}  coam.Get Alarms  alias=default
    Set Test Variable    ${ALARMS_AFTER_TEST}    ${active_alarm}
    ${alarms_cleared}    ${alarms_raised}    Compare Alarm List    ${ALARMS_BEFORE_TEST}    ${ALARMS_AFTER_TEST}    ${IGNORE_ALARM_FILTER}
    ${count}    Get Length    ${alarms_raised}
    Should Be Equal As Integers    ${count}    ${0}

Set ${param} Value To ${value} via Delta Recommission For ${mo}
    Log To Console    Set ${param} Value To ${value} via Delta Recommission For ${mo}
    coam.Perform Delta Recommissioning
    ...    [{"distName": "${mo}", "operation": "update", "parameters": [{"parameterName": "${param}", "operation": "update", "value": "${value}"}]}]
    ...    True

Check Other RAT Status
    Run Keyword If    ${GSM_cell_ids}    coam.Assert Every    GNCEL    ${cells_GSM_expected_state}
    Run Keyword If    ${WCDMA_cell_ids}    coam.Assert Every    WNCEL    ${cells_WCDMA_expected_state}
    Run Keyword If    ${LTE_cell_ids}    coam.Assert Every    LNCEL    ${cells_LTE_expected_state}
    ${current_btsInfo}    coam.Get Bts Info
    Run Keyword If    ${GSM_cell_ids}    Should Be Equal As Strings     ${current_btsInfo['ratState']['gsm']}    ALL_ENABLED
    Run Keyword If    ${WCDMA_cell_ids}   Should Be Equal As Strings     ${current_btsInfo['ratState']['wcdma']}    ALL_ENABLED
    Run Keyword If    ${LTE_cell_ids}   Should Be Equal As Strings     ${current_btsInfo['ratState']['lte']}    ALL_ENABLED

Collect Infomodel With Timestamp
    Log To Console   IMS log will be collected
    ${timestamp}    Generate Formatted Timestamp
    ${ims_collected}=  Run keyword And Return Status    Save Infomodel Log
    ...    filename=${BTS Files}/IM/Loop${current_loop_index}_InfoModel_log_${timestamp}.ims2  timeout=300
    Run keyword if  ${ims_collected}  Log    IMS collected to 'BTS Files'  level=INFO  console=${TRUE}
    ...  ELSE  Log    IMS collection failed     level=ERROR     console=${TRUE}
    Teardown Infomodel

Collect Syslog When Fail
    Run Keyword If  ${SMOD1_syslog_started}    Collect Syslog For SMOD1 With Timestamp
    Run Keyword If  ${SMOD2_syslog_started}    Collect Syslog For SMOD2 With Timestamp

Collect Syslog For ${SMOD} With Timestamp
    Log To Console   ${SMOD} syslog will be collected
    ${timestamp}    Generate Formatted Timestamp
    ${syslog_collected}=  Run keyword And Return Status  Collect syslog results  alias=${SMOD}
    ...  destination=${UDP Logs}/Loop${current_loop_index}_${SMOD}_UDP_${timestamp}.tar.gz  unzip=false
    Run keyword if  ${syslog_collected}  Log  ${SMOD} syslog collected to 'UDP Logs'    level=INFO      console=${TRUE}
    ...  ELSE  Log  ${SMOD} syslog collection failed      level=ERROR    console=${TRUE}


SBTS Recovery
    ${current_btsInfo}    coam.Get Bts Info
    ${status}    Run Keyword And Return Status    Should Be Equal As Strings
    ...    ${current_btsInfo['nrDU'][0]['status']['administrativeState']}    ${_Com_Unlocked_}
    Run Keyword If    not ${status}    Set administrativeState Value To ${_Com_Unlocked_} via Delta Recommission For ${NRDU_DN}
    ${status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    3x    10 sec
    ...    coam.Assert Every    NRCEL   operationalState=${_Enabled_}
    Run Keyword If    not ${status}     Run Keywords    Log    Will perform full commissioning with backup scf!    level=WARN
    ...    AND    coam.perform_commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=${SKIP_PARAM_RELATION_ERRORS}    timeout=600
    ...    AND    Wait Until Keyword Succeeds    20 min    30 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms

Restart Infomodel And Syslog
    Run Keyword And Continue On Failure    Teardown All Aliases For Syslog
    Run Keyword And Continue On Failure    Teardown All Aliases For Infomodel
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    3x    60s    Start Infomodel
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    3x    60s    Start syslog on SMOD1
    Run Keyword If  ${SMOD2_exists}
    ...    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    3x    60s    Start syslog on SMOD2

LoopTearDown
    Run Keyword And Continue On Failure    Admin Get Snapshot
    Run Keyword And Continue On Failure    Collect Infomodel With Timestamp
    Run Keyword And Continue On Failure    Collect Syslog When Fail
    SBTS Recovery

SetUp
    Common Test Setup SBTS    scf_check=${FALSE}
    ${btsInfo}    coam.Get Bts Info
    Set Test Variable    ${nrbts_id}    ${btsInfo['nrBtsId']}
    Set Test Variable    ${mrbts_id}    ${btsInfo['mrbtsID']}
    Set Test Variable    ${NRDU_DN}    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRDU-1
    Get Cell IDs for All RAT
    ${active_alarm}    coam.Get Alarms    alias=default
    Set Test Variable    ${ALARMS_BEFORE_TEST}    ${active_alarm}
    ${filter_list}    Create List
    FOR    ${str}    IN    @{IGNORE_ALARM_FILTER_STRING}
        &{filter}    Evaluate    ${str}
        Append To List    ${filter_list}    ${filter}
    END
    Set Test Variable    ${IGNORE_ALARM_FILTER}    ${filter_list}

CaseTearDown
    SBTS Recovery
    Run Keyword And Ignore Error    Run Keyword If Test Passed    Report To Rep With SCF Id
    Run Keyword If  '${bts_verification_status}'=='norun' and ${admin_started}==${TRUE}
    ...    Log  Initial verification of BTS states was not completed due to timeout, or some unit indicates a faulty state    level=WARN
    Teardown All Aliases For Syslog
    Teardown All Aliases For Infomodel
    coam.Teardown All Aliases For Admin
    Collect Swconfigs
    Collect RawAlarmHistory
    # hran_ta postcondititons:
    hran_general.Hran_ta Postconditions
    Run keyword if  'STOPONFAIL' in @{TEST TAGS} and '${TEST STATUS}' == 'FAIL'
    ...    Fatal error  Execution stopped because critical TC '${TEST NAME}' failed
	#gnb_tool.stop_and_fix