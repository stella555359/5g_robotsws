*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${REPEAT_TIME}    1
${ALARMS_BEFORE_TEST}    ${EMPTY}
${ALALRMS_AFTER_TEST}    ${EMPTY}
${REPEAT_TESTING_FAIL}    False
@{IGNORE_ALARM_FILTER_STRING}    {'faultId':61649}    {'faultId':61074}    {'faultId':4639}    {'faultId':4459}    {'faultId':8000}
${SKIP_PARAM_RELATION_ERRORS}    True

*** Keywords ***
CM__Repeat_RF_BB_Module_Lock_And_Reset_Parallel_By_HWRESET_via_AdminAPI
    [Documentation]    [CASE MRT]: RAN_SyVe_CM_Repeat_Recommission_with_HWRESET_via_WebEM
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    Repeat to reset RMOD and BBMOD by delta commission
    ...
    ...    The main steps performed for the test are:
    ...     . Select RMOD BBMOD Randomly
    ...     . Repeat Reset RMOD AND BBMOD Via Admin Delta Plan Recommission
    ...    Pass criteria: random selected module from all RMOD and BBMOD twice, parallel do 1 module reset and anotehr lock/unlock,
    ...    HWRESETRES result is success and lock/unlock status ok. No need to check relate cell status.
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 17.01.2022 - Kang Lixin - New case
    Set Tags    CM    AUTHOR-lixin.kang@nokia-sbell.com     OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Select Modules Randomly
    Step 2: Repeat RMOD And BBMOD Lock And Reset Via Admin Delta Plan Recommission

Step ${index}: Repeat RMOD And BBMOD Lock And Reset Via Admin Delta Plan Recommission
    ${REPEAT_TIME}    Evaluate    int(${REPEAT_TIME})
    ${failed_loops}    Create List
    FOR    ${index}    IN RANGE    1    ${REPEAT_TIME+1}
        Restart Infomodel And Syslog
        Set Test Variable    ${current_loop_index}    ${index}
        ${reset_oper_status}    Run Keyword And Return Status    Lock And Reset Module Parallel From Admin
        Continue For Loop If    ${reset_oper_status}
        Log    Lock And Reset Module Parallel Failed at Loop${current_loop_index}    console=${True}    level=ERROR
        Append To List    ${failed_loops}    ${current_loop_index}
        LoopTearDown
        Set Test Variable    ${REPEAT_TESTING_FAIL}    True
    END
    Run Keyword If    ${REPEAT_TESTING_FAIL}    Fail    Repeat Lock And Reset Module Parallel Failed at Loop @{failed_loops}!

Step ${index}: Select Modules Randomly
    LOG    Step ${index}: Select Modules Randomly    console=${True}
    ${btsInfo}    coam.Get Bts Info
    ${rmod_list}    Set Variable    ${btsInfo['radioModules']['rmod']}
    ${bbmod_list}     Set Variable    ${btsInfo['basebandModules']}
    FOR    ${item}    IN    @{rmod_list}
        ${rmod_scf_dn}    Set Variable    ${item['id']['configuration']}
        ${status}    ${radioMasterDN}    Run Keyword And Ignore Error    Get Parameter Value From WebEM    ${rmod_scf_dn}    radioMasterDN
        ${is_rfsharing_slave}    Run Keyword And Return Status    Should Contain    ${radioMasterDN}    MRBTS-${mrbts_id}/EQM-1/SMOD_EXT-
        Run Keyword If    ${is_rfsharing_slave}   Remove Values From List    ${rmod_list}    ${item}
    END
    FOR    ${bbmod}    IN    @{bbmod_list}
        Run Keyword If    '${bbmod['productName']}'=='ABIA AirScale Capacity'    Remove Values From List    ${bbmod_list}    ${bbmod}
    END
    ${bbmod_id_list}    Create List
    FOR    ${bbmod}    IN    @{bbmod_list}
        Append To List    ${bbmod_id_list}    ${bbmod['id']['configuration']}:${bbmod['id']['internal']}
    END
    ${rmod_id_list}    Create List
    FOR    ${rmod}    IN    @{rmod_list}
        Append To List    ${rmod_id_list}    ${rmod['id']['configuration']}:${rmod['id']['internal']}
    END
    ${combined_module_list}    Combine Lists    ${bbmod_id_list}    ${rmod_id_list}
    ${count}    Get Length    ${combined_module_list}
    ${MOD_TO_LOCK_ID}    Evaluate    random.choice(${combined_module_list})    modules=random, sys
    ${MOD_TO_LOCK_CONFIG_ID}    Fetch From Left    ${MOD_TO_LOCK_ID}   :
    ${MOD_TO_LOCK_INTERNAL_ID}    Fetch From Right   ${MOD_TO_LOCK_ID}    :
    Set Test Variable    ${MOD_TO_LOCK_CONFIG_ID}
    Set Test Variable    ${MOD_TO_LOCK_INTERNAL_ID}
    ${module_name}    Fetch From Right    ${MOD_TO_LOCK_CONFIG_ID}    /
    ${MOD_TYPE_TO_LOCK}    Fetch From Left    ${module_name}    -
    Set Test Variable    ${MOD_TYPE_TO_LOCK}
    ${MOD_TO_RESET_ID}    Evaluate    random.choice(${combined_module_list})    modules=random, sys
    ${MOD_TO_RESET_CONFIG_ID}    Fetch From Left    ${MOD_TO_RESET_ID}   :
    ${MOD_TO_RESET_INTERNAL_ID}    Fetch From Right   ${MOD_TO_RESET_ID}    :
    Set Test Variable    ${MOD_TO_RESET_CONFIG_ID}
    Set Test Variable    ${MOD_TO_RESET_INTERNAL_ID}
    ${module_name}    Fetch From Right    ${MOD_TO_RESET_CONFIG_ID}    /
    ${MOD_TYPE_TO_RESET}    Fetch From Left    ${module_name}    -
    Set Test Variable    ${MOD_TYPE_TO_RESET}

Lock And Reset Module Parallel From Admin
    Log To Console    Start Lock And Reset Module Parallel From Admin ...
    Run Keyword And Ignore Error    Delete CMD Object via Delta Recommission
    Lock And Reset Module Parallel Via Delta Plan Recommission
    Check Module Reset Behavior
    Unlock Module Via Delta Plan Recommission
    Wait Until Keyword Succeeds    10 min    10 sec    Check SBTS SMOD RMOD Cells Alarms
    ${active_alarm}  coam.Get Alarms  alias=default
    Set Test Variable    ${ALARMS_AFTER_TEST}    ${active_alarm}
    ${alarms_cleared}    ${alarms_raised}    Compare Alarm List    ${ALARMS_BEFORE_TEST}    ${ALARMS_AFTER_TEST}    ${IGNORE_ALARM_FILTER}
    ${count}    Get Length    ${alarms_raised}
    Should Be Equal As Integers    ${count}    ${0}

Check Module Reset Behavior
    Log To Console    Check Module Reset Behavior
    Wait Until Keyword Succeeds    3 min    2 sec    coam.Assert     ${MOD_TYPE_TO_RESET}     ${MOD_TO_RESET_INTERNAL_ID}
    ...                                                              operationalState=${_Disabled_}
    Wait Until Keyword Succeeds    15 min    2 sec    coam.Assert    ${MOD_TYPE_TO_RESET}     ${MOD_TO_RESET_INTERNAL_ID}
    ...                                                              operationalState=${_Enabled_}
    Wait Until Keyword Succeeds    3 min    3 sec    Check HWRESETRES Result
    coam.Assert    ${MOD_TYPE_TO_LOCK}    ${MOD_TO_LOCK_INTERNAL_ID}    ${BBMOD_locked_state}    timeout=30s
    Check BTS Not Restart From IMS

Check HWRESETRES Result
    ${BTS_scf_content}=   coam.Get SCF    export_type=configurationAndRuntimeObjects
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${BTS_scf_content}
    ${HWRESETRES_Result}    L_XML.Get Element Text    ${scf_xml}
    ...  .//managedObject[@distName="MRBTS-${mrbts_id}/MNL-1/CMD-1/HWRESETREQ-1/HWRESETRES-1"]/p[@name="hwResetResult"]
    Should Be Equal As Strings    success    ${HWRESETRES_Result}

Lock And Reset Module Parallel Via Delta Plan Recommission
    Log To Console    Lock And Reset Module Parallel Via Delta Plan Recommission
    ${tmp1}    Set Variable    [{"distName": "MRBTS-${mrbts_id}/MNL-1/CMD-1", "operation": "create", "parameters": [{"parameterName": "cmdId",
    ${tmp2}    Set Variable    "operation": "update", "value": "1"}]},{"distName": "MRBTS-${mrbts_id}/MNL-1/CMD-1/HWRESETREQ-1", "operation":"create"
    ${tmp3}    Set Variable     ,"parameters": [{"parameterName": "targetHwResetUDN", "operation": "update", "value": "${MOD_TO_RESET_CONFIG_ID}"}]},
    ${tmp4}    Set Variable    {"distName": "${MOD_TO_LOCK_CONFIG_ID}", "operation": "update", "parameters": [{"parameterName":
    ${tmp5}    Set Variable    "administrativeState", "operation": "update", "value": "${_Com_Locked_}"}]}]
    coam.Perform Delta Recommissioning    ${tmp1}${tmp2}${tmp3}${tmp4}${tmp5}    True

Unlock Module Via Delta Plan Recommission
    Log To Console    Unlock Module Via Delta Plan Recommission
    ${tmp1}    Set Variable    [{"distName": "${MOD_TO_LOCK_CONFIG_ID}", "operation": "update", "parameters": [{"parameterName":
    ${tmp2}    Set Variable    "administrativeState", "operation": "update", "value": "${_Com_Unlocked_}"}]}]
    coam.Perform Delta Recommissioning    ${tmp1}${tmp2}   True

Delete CMD Object via Delta Recommission
    Log To Console    Delete CMD Object via Delta Recommission
    coam.Perform Delta Recommissioning    [{"distName": "MRBTS-${mrbts_id}/MNL-1/CMD-1", "operation": "delete", "parameters": []}]    True

Check All Cell Status Online
    Log To Console    Check All Cell Status Online ...
    ${are_gcells_online}    Check If All Objects Are Online    GNCEL    10 sec
    ...    administrativeState=${_Com_Unlocked_}    operationalState=${_Enabled_}    blockingState=${_Unblocked_}
    ...    usageState=${_Active_}
    ${are_wcells_online}    Check If All Objects Are Online    WNCEL    10 sec
    ...    operationalState=${_Enabled_}    blockingState=${_Unblocked_}    usageState=${_Active_}
    ${are_lcells_online}    Check If All Objects Are Online    LNCEL    10 sec
    ...    administrativeState=${_Unlocked_}    operationalState=${_Enabled_}    blockingState=${_Unblocked_}    proceduralState=${_OnAirDone_}
    ${are_nrcells_online}    Check If All Objects Are Online     NRCEL    10 sec
    ...    administrativeState=${_Com_Unlocked_}    blockingState=${_Unblocked_}    operationalState=${_Enabled_}
    ${condition1}    Set Variable   "${are_gcells_online}"=="PASS" and "${are_wcells_online}"=="PASS"
    ${condition2}    Set Variable   "${are_lcells_online}"=="PASS" and "${are_nrcells_online}"=="PASS"
    Should be true    ${condition1} and ${condition2}    Not all conditions were satisfied!

Check BTS Not Restart From IMS
    ${ims2_file_path_name}    Set Variable    ${BTS Files}/IM/Loop${current_loop_index}_check_no_restart_InfoModel_log.ims2
    ${reset_was_triggered}    Infomodel Check IM log if BTS reset was triggered    ${ims2_file_path_name}
    Should Not Be True    ${reset_was_triggered}

Collect Infomodel With Timestamp
    Log To Console   IMS log will be collected
    ${timestamp}    Generate Formatted Timestamp
    ${ims_collected}     Run keyword And Return Status    Save Infomodel Log
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
    ${syslog_collected}     Run keyword And Return Status  Collect syslog results  alias=${SMOD}
    ...  destination=${UDP Logs}/Loop${current_loop_index}_${SMOD}_UDP_${timestamp}.tar.gz  unzip=false
    Run keyword if  ${syslog_collected}  Log  ${SMOD} syslog collected to 'UDP Logs'    level=INFO      console=${TRUE}
    ...  ELSE  Log  ${SMOD} syslog collection failed      level=ERROR    console=${TRUE}

SBTS Recovery
    ${site_onair}    Run Keyword And Return Status    Wait Until Keyword Succeeds    5 min    10 sec    Check All Cell Status Online
    Run Keyword If    not ${site_onair}
    ...    Run Keywords    Log    Will perform full commissioning with backup scf!    level=WARN
    ...    AND    coam.perform_commissioning    bts_id=${mrbts_id}    scf_file=${BTS_scf_initial}
    ...    skip_parameter_relation_errors=${SKIP_PARAM_RELATION_ERRORS}    timeout=600
    ...    AND    Wait Until Keyword Succeeds    20 min    30 sec    Check SBTS SMOD RMOD Cells Alarms
    Run Keyword And Ignore Error    Delete CMD Object via Delta Recommission

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
    Get Cell IDs for All RAT
    ${btsInfo}    coam.Get Bts Info
    Set Test Variable    ${mrbts_id}    ${btsInfo['mrbtsID']}
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