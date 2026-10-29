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
CM__Repeat_BB_Module_Lock_Unlock_via_AdminAPI
    [Documentation]    [CASE MRT]: RAN_SyVe_CM_Repeat_BB_Module_Lock_Unlock_via_WebEM
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    Repeat to Lock/Unlock the BBMOD by delta commission: Change BBMOD administrativeState to
    ...    Locked/Unlocked through ADMIN API
    ...
    ...    The main steps performed for the test are:
    ...     . Select One BBMOD Randomly
    ...     . Repeat Lock Unlock BB Module
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 17.01.2022 - Kang Lixin - New case
    Set Tags    CM    AUTHOR-lixin.kang@nokia-sbell.com     OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Select One BBMOD Randomly
    Step 2: Repeat Lock Unlock BB Module

Step ${index}: Repeat Lock Unlock BB Module
    ${REPEAT_TIME}    Evaluate    int(${REPEAT_TIME})
    ${failed_loops}    Create List
    FOR    ${index}    IN RANGE    1    ${REPEAT_TIME+1}
        Restart Infomodel And Syslog
        Set Test Variable    ${current_loop_index}    ${index}
        ${lock_oper_status}    Run Keyword And Return Status    Lock BB Module From Admin
        Run Keyword If    not ${lock_oper_status}    Run Keywords    Log    Lock BB Module Failed at Loop${current_loop_index}
        ...    console=${True}    level=ERROR
        ...    AND    Append To List    ${failed_loops}    ${current_loop_index}
        ...    AND    LoopTearDown
        ...    AND    Set Test Variable    ${REPEAT_TESTING_FAIL}    True
        ...    AND    Continue For Loop
        ${unlock_oper_status}    Run Keyword And Return Status    Unlock BB Module From Admin
        Run Keyword If    not ${unlock_oper_status}    Run Keywords    Log    Unlock BB Module Failed at Loop${current_loop_index}
        ...    console=${True}    level=ERROR
        ...    AND    Append To List    ${failed_loops}    ${current_loop_index}
        ...    AND    LoopTearDown
        ...    AND    Set Test Variable    ${REPEAT_TESTING_FAIL}    True
        ...    AND    Continue For Loop
    END
    Run Keyword If    ${REPEAT_TESTING_FAIL}    Fail    Repeat Lock Unlock BB Module failed at loop @{failed_loops}!

Step ${index}: Select One BBMOD Randomly
    ${count}    Get Length    ${bbmod_list}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${BBMOD_TO_OPER_CONFIG}    Set Variable    ${bbmod_list[${index}]['id']['configuration']}
    ${BBMOD_TO_OPER_INTERNAL}    Set Variable    ${bbmod_list[${index}]['id']['internal']}
    Set Test Variable    ${BBMOD_TO_OPER_CONFIG}
    Set Test Variable    ${BBMOD_TO_OPER_INTERNAL}
    Set Test Variable    ${expect_disabled_cell_dic}    ${bbmod_cell_mapping['${BBMOD_TO_OPER_INTERNAL}']}
    ${online_GNCEL_ids}    Copy List    ${GSM_cell_ids}
    ${online_WNCEL_ids}    Copy List    ${WCDMA_cell_ids}
    ${online_LNCEL_ids}    Copy List    ${LTE_cell_ids}
    ${online_NRCEL_ids}    Copy List    ${NR_cell_ids}
    Set Test Variable     ${online_GNCEL_ids}
    Set Test Variable     ${online_WNCEL_ids}
    Set Test Variable     ${online_LNCEL_ids}
    Set Test Variable     ${online_NRCEL_ids}

Lock BB Module From Admin
    Log To Console    Lock BB Module From Admin
    Set administrativeState Value To ${_Com_Locked_} via Delta Recommission For ${BBMOD_TO_OPER_CONFIG}
    coam.Assert    BBMOD    ${BBMOD_TO_OPER_INTERNAL}    ${BBMOD_locked_state}
    Check All Cell Status As Expected
    ${active_alarm}  coam.Get Alarms  alias=default
    Set Test Variable    ${ALARMS_AFTER_TEST}    ${active_alarm}
    ${alarms_cleared}    ${alarms_raised}    Compare Alarm List    ${ALARMS_BEFORE_TEST}    ${ALARMS_AFTER_TEST}    ${IGNORE_ALARM_FILTER}
    ${count}    Get Length    ${alarms_raised}
    Should Be Equal As Integers    ${count}    ${0}

Unlock BB Module From Admin
    Log To Console    Unlock BB Module From Admin
    Set administrativeState Value To ${_Com_Unlocked_} via Delta Recommission For ${BBMOD_TO_OPER_CONFIG}
    coam.Assert    BBMOD    ${BBMOD_TO_OPER_INTERNAL}    ${BBMOD_expected_state}
    Wait Until Keyword Succeeds    8 min    30 sec    Check All Cell Status Online
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

Check All Cell Status As Expected
    ${disabled_gncel_list}    Set Variable    ${expect_disabled_cell_dic['GSM']}
    ${disabled_wncel_list}    Set Variable    ${expect_disabled_cell_dic['WCDMA']}
    ${disabled_lncel_list}    Set Variable    ${expect_disabled_cell_dic['LTE']}
    ${disabled_nrcel_list}    Set Variable    ${expect_disabled_cell_dic['5G']}
    ${cell_disabled_status}    Set Variable    blockingState=${_Unblocked_}, operationalState=${_Disabled_}, availabilityStatus=${_Dependency_}
    Check BBMOD Related Cell Status As Expected    GNCEL    ${disabled_gncel_list}    ${cell_disabled_status}
    Check BBMOD Related Cell Status As Expected    WNCEL    ${disabled_wncel_list}    ${cell_disabled_status}
    Check BBMOD Related Cell Status As Expected    LNCEL    ${disabled_lncel_list}    ${cell_disabled_status}
    Check BBMOD Related Cell Status As Expected    NRCEL    ${disabled_nrcel_list}    ${cell_disabled_status}
    Check Online Cell Status As Expected    GNCEL    ${online_GNCEL_ids}    ${cells_GSM_expected_state}
    Check Online Cell Status As Expected    WNCEL    ${online_WNCEL_ids}    ${cells_WCDMA_expected_state}
    Check Online Cell Status As Expected    LNCEL    ${online_LNCEL_ids}    ${cells_LTE_expected_state}
    Check Online Cell Status As Expected    NRCEL    ${online_NRCEL_ids}    ${cells_NR_expected_state}

Check BBMOD Related Cell Status As Expected
    [Arguments]     ${tech_cell}    ${cell_id_list}    ${expected_status}
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${dic_cell_state}    coam.Assert    ${tech_cell}    ${cell_id}    ${expected_status}
        Remove Values From List    ${online_${tech_cell}_ids}    ${cell_id}
        ${dic_nbIoTCell_state}    Pop From Dictionary    ${dic_cell_state}    nbIoTCell    ${None}
        Continue For Loop If    ${dic_nbIoTCell_state} is ${None}
        ${cell_disabled_status}    Create Dictionary    blockingState=${_Unblocked_}
        ...        availabilityStatus=${Offline_}    operationalState=${_Disabled_}
        ${str_cell_state}    coam.Assert    ${tech_cell}    ${dic_nbIoTCell_state['distName']}
        ${dic_cell_state}    Convert To Dictionary    ${str_cell_state}
        Dictionary Should Contain Sub Dictionary    ${dic_cell_state}    ${cell_disabled_status}
        Remove Values From List    ${online_${tech_cell}_ids}    ${dic_nbIoTCell_state['distName']}
    END

Check Online Cell Status As Expected
    [Arguments]     ${tech_cell}    ${cell_id_list}    ${expected_status}
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${dic_cell_state}    coam.Assert    ${tech_cell}    ${cell_id}    ${expected_status}
        ${dic_nbIoTCell_state}    Pop From Dictionary    ${dic_cell_state}    nbIoTCell    ${None}
        Continue For Loop If    ${dic_nbIoTCell_state} is ${None}
        ${str_cell_state}    coam.Assert    ${tech_cell}    ${dic_nbIoTCell_state['distName']}
        ${dic_cell_state}    Convert To Dictionary    ${str_cell_state}
        ${dic_expected_status}    Create Dictionary    administrativeState=${_Unlocked_}    operationalState=${_Enabled_}
        ...    blockingState=${_Unblocked_}    proceduralState=${_OnAirDone_}
        Dictionary Should Contain Sub Dictionary    ${dic_cell_state}    ${dic_expected_status}
    END

Check All Cell Status Online
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

Setup Relationship Between BBMOD Cells-discard
    ${bbmod_cell_mapping}    Create Dictionary
    ${full_scf}    coam.Get Scf    configurationAndRuntimeObjects
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${full_scf_xml}    L_XML.Parse Xml    ${full_scf}
    Set Test Variable    ${full_scf_xml}
    XML.Save Xml    ${full_scf_xml}    cur_scf.xml
    FOR    ${bbmod}    IN    @{bbmod_list}
        ${cell_dic}    Get BBMOD Related Cells    ${bbmod['id']['runtime']}
        Set To Dictionary    ${bbmod_cell_mapping}    ${bbmod['id']['internal']}    ${cell_dic}
    END
    Set Test Variable    ${bbmod_cell_mapping}

Get BBMOD Related Cells-discard
    [Arguments]    ${BBMOD_MO_R}
    [Documentation]    Get 2G/3G/4G/5G cells related to BBMOD.
    ${empty_list}    Create List
    ${cell_dic}    Create Dictionary    GSM=${empty_list}    WCDMA=${empty_list}    LTE=${empty_list}    5G=${empty_list}
    ${bbpool_has_bbmod_r}    L_XML.Get Elements    ${full_scf_xml}
    ...    .//managedObject[@class="com.nokia.srbts.mnl:BBPOOL"]/list[@name="bbPwrGroupDNList"][contains(p,"${BBMOD_MO_R}")]
    ${cnt}     Get Length    ${bbpool_has_bbmod_r}
    Return From Keyword If    ${cnt}==0    ${cell_dic}
    ${MO_BBPOOL}    L_XML.Get Elements    ${full_scf_xml}    .//managedObject[@class="com.nokia.srbts.mnl:BBPOOL"]
    FOR    ${MO}    IN    @{MO_BBPOOL}
        ${bbPwrGroupDNList}    L_XML.Get Elements    ${MO}    .//list[@name="bbPwrGroupDNList"][contains(p,"${BBMOD_MO_R}")]
        Run Keyword If    ${bbPwrGroupDNList}    Get Tech Cells Mapping From BBPOOL     ${MO}     ${cell_dic}
    END
    [Return]    ${cell_dic}

Get Tech Cells Mapping From BBPOOL-discard
    [Arguments]     ${bbpool_elememt}    ${cell_dic}
    ${bbPoolTech}    L_XML.Get Element Text    ${bbpool_elememt}    .//p[@name="bbPoolTech"]
    ${bbPoolCellsList}    L_XML.Get Elements Texts    ${bbpool_elememt}    .//list[@name="bbPoolCellsList"]/p
    ${bbmod_related_cells_id}    Run Keyword If    '${bbPoolTech}'=='WCDMA'    Fetch WCDMA Cell List By Cellmapping ID    ${bbPoolCellsList}
    ...    ELSE    Fetch NON-WCDMA Cell List By Cellmapping ID BB   ${bbPoolCellsList}    ${bbPoolTech}
    ${tmp_list}    Combine Lists    ${cell_dic['${bbPoolTech}']}    ${bbmod_related_cells_id}
    ${tmp_list}    Remove Duplicates    ${tmp_list}
    Set To Dictionary    ${cell_dic}    ${bbPoolTech}    ${tmp_list}

Fetch NON-WCDMA Cell List By Cellmapping ID BB-discard
    [Arguments]     ${cellmappings}    ${bbPoolTech}
    ${cell_list}    Create List
    FOR    ${cellmid}    IN    @{cellmappings}
        ${cell_dn}    Set Variable If
        ...    '${bbPoolTech}'=='GSM'    MRBTS-${mrbts_id}/GNBTS-1/GNBCF-1/GNCEL-${cellmid}
        ...    '${bbPoolTech}'=='LTE'    MRBTS-${mrbts_id}/LNBTS-${lnbts_id}/LNCEL-${cellmid}
        ...    '${bbPoolTech}'=='5G'    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${cellmid}
        ${cell_id_mapping}    Fetch ID Mapping From Admin For Cells    identifier=${cell_dn}    identifier_type=configuration
        Append To List     ${cell_list}    ${cell_id_mapping['internal']}
    END
    [Return]     ${cell_list}

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
    ${status}    Run Keyword And Return Status    coam.Assert Every    BBMOD    ${BBMOD_expected_state}
    Run Keyword If    not ${status}
    ...    Set administrativeState Value To ${_Com_Unlocked_} via Delta Recommission For ${BBMOD_TO_OPER_CONFIG}
    ${status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    8 min    10 sec
    ...    Check All Cell Status Online
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
    Get Cell IDs for All RAT
    ${btsInfo}    coam.Get Bts Info
    Set Test Variable    ${mrbts_id}    ${btsInfo['mrbtsID']}
    Set Test Variable    ${bbmod_list}     ${btsInfo['basebandModules']}
    ${nrbts_id}    Run Keyword If    ${NR_cell_ids}    Set Variable    ${btsInfo['nrBtsId']}
    Set Test Variable    ${nrbts_id}
    ${lnbts}    coam.Get Ids For All    LNBTS
    ${lnbts_r}=    Fetch From Right    ${lnbts[0]}    /
    ${lnbts_id}=    Get Substring    ${lnbts_r}    8
    Set Test Variable    ${lnbts_id}
    # Setup Relationship Between BBMOD Cells
    ${bbmod_cell_mapping}    Get Relationship Between BBMODs And Cells
    Set Test Variable    ${bbmod_cell_mapping}
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
    Run Keyword And Ignore Error	Run Keyword If Test Passed	Report To Rep With SCF Id
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