*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${REPEAT_TIME}    10
${CELL_NUMBER_TO_TEST}   1   # If set to 0, will operation on all nrcells
${ALARMS_BEFORE_TEST}    ${EMPTY}
${ALALRMS_AFTER_TEST}    ${EMPTY}
${REPEAT_TESTING_FAIL}    False
@{IGNORE_ALARM_FILTER_STRING}    {'faultId':61649}    {'faultId':61074}    {'faultId':4639}    {'faultId':4459}    {'faultId':8000}
${SKIP_PARAM_RELATION_ERRORS}    True

*** Keywords ***
CM__Repeat_5G_Cell_Lock_Unlock_via_AdminAPI
    [Documentation]    [CASE MRT]: RAN_SyVe_CM_Repeat_5G_Cell_Lock_Unlock_via_WebEM
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    Repeat to Lock/Unlock the same 5G Cell or Cells by delta commision: Change NRCELL administrativeState to
    ...    Locked/Unlocked through ADMIN API
    ...    Can choose 1 nrcell, more nrcells or all nrcells by setting variable CELL_NUMBER_TO_TEST
    ...
    ...    The main steps performed for the test are:
    ...    . Select NRCELL
    ...    . Repeat Lock Unlock Selected NRCELL
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 21.12.2021 - Kang Lixin - New case

    Set Tags    CM    AUTHOR-lixin.kang@nokia-sbell.com     OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Select NRCELL
    Step 2: Repeat Lock Unlock Selected NRCELL

Step ${index}: Select NRCELL
    LOG    Step ${index}: Select NRCELL    console=${True}
    ${cell_list}    coam.Get Cell List
    Set Test Variable    ${nr_cell_list}    ${cell_list['cells']['nr']}
    ${count}    Get Length    ${nr_cell_list}
    Set Test Variable    ${nrcell_amount}    ${count}
    ${CELL_NUMBER_TO_TEST}    Evaluate    int(${CELL_NUMBER_TO_TEST})
    ${result}    Evaluate     0<${CELL_NUMBER_TO_TEST}<${nrcell_amount}
    ${cells_amount_to_test}    Set Variable If    ${result}    ${CELL_NUMBER_TO_TEST}    ${nrcell_amount}
    Set Test Variable    ${cells_amount_to_test}
    ${CELL_TO_LOCK}    Create List
    ${CELL_TO_LOCK_ID}    Create List
    ${REST_NRCELL_ID}    Create List
    Set Test Variable    ${CELL_TO_LOCK}
    Set Test Variable    ${CELL_TO_LOCK_ID}
    Set Test Variable    ${REST_NRCELL_ID}
    Select NRCELL Randomly

Step ${index}: Repeat Lock Unlock Selected NRCELL
    ${REPEAT_TIME}    Evaluate    int(${REPEAT_TIME})
    ${failed_loops}    Create List
    FOR    ${index}    IN RANGE    1    ${REPEAT_TIME+1}
        Restart Infomodel And Syslog
        Set Test Variable    ${current_loop_index}    ${index}
        ${lock_oper_status}    Run Keyword And Return Status    Lock Selected NRCELL From Admin
        Run Keyword If    not ${lock_oper_status}    Run Keywords    Log    Lock NRCELL Failed at Loop${current_loop_index}
        ...    console=${True}    level=ERROR
        ...    AND    Append To List    ${failed_loops}    ${current_loop_index}
        ...    AND    LoopTearDown
        ...    AND    Set Test Variable    ${REPEAT_TESTING_FAIL}    True
        ...    AND    Continue For Loop
        ${unlock_oper_status}    Run Keyword And Return Status    Unlock Selected NRCELL From Admin
        Run Keyword If    not ${unlock_oper_status}    Run Keywords    Log    Unlock NRCELL Failed at Loop${current_loop_index}
        ...    console=${True}    level=ERROR
        ...    AND    Append To List    ${failed_loops}    ${current_loop_index}
        ...    AND    LoopTearDown
        ...    AND    Set Test Variable    ${REPEAT_TESTING_FAIL}    True
        ...    AND    Continue For Loop
        ${need_restart}    Evaluate    ${index}/${70}>1 or ${index}/${70}==1
        Run Keyword If     ${need_restart}    Restart Admin
    END
    Run Keyword If    ${REPEAT_TESTING_FAIL}    Fail    Repeat Lock Unlock NRCELL failed at loop @{failed_loops}!

Select NRCELL Randomly
    Set Test Variable    ${REST_NRCELL_ID}    ${NR_cell_ids}
    FOR    ${index}    IN RANGE    1    ${cells_amount_to_test+1}
        ${selected_cell}    Evaluate    random.choice(${nr_cell_list})    modules=random, sys
        Append To List    ${CELL_TO_LOCK}    ${selected_cell['id']['configuration']}
        Append To List    ${CELL_TO_LOCK_ID}    ${selected_cell['id']['internal']}
        Remove Values From List    ${nr_cell_list}    ${selected_cell}
        Remove Values From List    ${REST_NRCELL_ID}    ${selected_cell['id']['internal']}
    END

Lock Selected NRCELL From Admin
    Log To Console    Lock Selected NRCELL From Admin
    Set administrativeState Value To ${_Com_Locked_} via Delta Recommission For NRCELL
    FOR    ${cel}    IN    @{CELL_TO_LOCK_ID}
        coam.Assert    NRCEL    ${cel}    ${cells_NR_locked_state}
    END
    FOR    ${cel}    IN    @{REST_NRCELL_ID}
        coam.Assert    NRCEL    ${cel}     ${cells_NR_expected_state}
    END
    Check Other Cell Status
    ${active_alarm}  coam.Get Alarms  alias=default
    Set Test Variable    ${ALARMS_AFTER_TEST}    ${active_alarm}
    ${alarms_cleared}    ${alarms_raised}    Compare Alarm List    ${ALARMS_BEFORE_TEST}    ${ALARMS_AFTER_TEST}    ${IGNORE_ALARM_FILTER}
    ${count}    Get Length    ${alarms_raised}
    Should Be Equal As Integers    ${count}    ${0}

Unlock Selected NRCELL From Admin
    Log To Console    Unlock Selected NRCELL From Admin
    Set administrativeState Value To ${_Com_Unlocked_} via Delta Recommission For NRCELL
    Wait Until Keyword Succeeds    6x    5 sec   coam.Assert Every    NRCEL    ${cells_NR_expected_state}
    Check Other Cell Status
    ${active_alarm}  coam.Get Alarms  alias=default
    Set Test Variable    ${ALARMS_AFTER_TEST}    ${active_alarm}
    ${alarms_cleared}    ${alarms_raised}    Compare Alarm List    ${ALARMS_BEFORE_TEST}    ${ALARMS_AFTER_TEST}    ${IGNORE_ALARM_FILTER}
    ${count}    Get Length    ${alarms_raised}
    Should Be Equal As Integers    ${count}    ${0}

Set ${param} Value To ${value} via Delta Recommission For NRCELL
    Log To Console    Set ${param} Value To ${value} via Delta Recommission For NRCELL
    ${delta_json}    Generate Delta Json Data    ${param}    ${value}
    coam.Perform Delta Recommissioning    ${delta_json}    True

Generate Delta Json Data
    [Arguments]     ${param}    ${value}
    ${tmp_str}    Set Variable    ${EMPTY}
    FOR    ${item}    IN    @{CELL_TO_LOCK}
      ${tmp_str}    Catenate    SEPARATOR=
      ...    ${tmp_str},
      ...  {"distName": "${item}", "operation": "update", "parameters": [{"parameterName": "${param}", "operation": "update", "value": "${value}"}]}
    END
    ${tmp_str}    Get Substring    ${tmp_str}    1
    ${delta_json}   Catenate     SEPARATOR=    [     ${tmp_str}
    ${delta_json}   Catenate     SEPARATOR=     ${delta_json}    ]
    [Return]    ${delta_json}

Check Other Cell Status
    Run Keyword If    ${GSM_cell_ids}    coam.Assert Every    GNCEL    ${cells_GSM_expected_state}
    Run Keyword If    ${WCDMA_cell_ids}    coam.Assert Every    WNCEL    ${cells_WCDMA_expected_state}
    Run Keyword If    ${LTE_cell_ids}    coam.Assert Every    LNCEL    ${cells_LTE_expected_state}

Collect Infomodel With Timestamp
    Log To Console   IMS log will be collected
    ${timestamp}    Generate Formatted Timestamp
    ${ims_collected}=  Run keyword And Return Status
    ...    Save Infomodel Log    filename=${BTS Files}/IM/Loop${current_loop_index}_InfoModel_log_${timestamp}.ims2  timeout=300
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
    ${status}    Run Keyword And Return Status    coam.Assert Every    NRCEL    administrativeState=${_Com_Unlocked_}
    Run Keyword If    not ${status}    Set administrativeState Value To ${_Com_Unlocked_} via Delta Recommission For NRCELL
    ${status}    Run Keyword And Return Status    coam.Assert Any    NRCEL   administrativeState=${_Com_Locked_}
    Run Keyword If    ${status}     Run Keywords    Log    Will perform full commissioning with backup scf!    level=WARN
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

Restart Admin
   Run Keyword And Continue On Failure    coam.Teardown All Aliases For Admin
   Run Keyword And Continue On Failure    Start Admin    bts_host=${SMOD1['TRS_IP']}

LoopTearDown
    Run Keyword And Continue On Failure    Admin Get Snapshot
    Run Keyword And Continue On Failure    Collect Infomodel With Timestamp
    Run Keyword And Continue On Failure    Collect Syslog When Fail
    SBTS Recovery

SetUp
    Common Test Setup SBTS    scf_check=${FALSE}
    Get Cell IDs for All RAT
    ${mrbts_id}    Fetch From Right    ${MRBTS_DN}    /
    Set Test Variable    ${mrbts_id}
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