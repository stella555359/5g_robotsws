*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${ALARMS_BEFORE_TEST}    ${EMPTY}
${ALALRMS_AFTER_TEST}    ${EMPTY}
${CELL_TO_REMOVE_LIST}    ${EMPTY}
${CELL_LINK_SHOULD_REMOVE_LIST}    ${EMPTY}
${NEED_RESTART_SBTS}    ${False}
${RATS_TO_RESET}    ${EMPTY}
@{IGNORE_ALARM_FILTER_STRING}    {'Fault ID':'61649'}    { 'Fault ID':'6286'}    { 'Fault ID':'61524'}
...               { 'Fault ID':'61074'}    { 'Fault ID':'4655'}    { 'Fault ID':'61652'}    { 'Fault ID':'4654'}
...               {'Fault ID':'2403','Alarm ID': '7115'}    {'Fault ID':'2403','Alarm ID': '7112'}

*** Keywords ***
CM__Sector_Addition_And_Deletion_Via_Parameter_Editor
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   - Source case:CRT_015_Automated__CM__Sector_Addition_And_Deletion_Via_Parameter_Editor.robot
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.05.2023 - Commit to robotws

    Set Tags    CM    UI    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Find Cell And Cell Mapping For Removal
    Step 2: Remove Cells And Cell Mappings
    Step 5: Set Reset Mode
    Step 6: Validate And Activate Plan Expect Error
    Step 7: Check Relative Seivices Has Restarted Successful After Cell Deletion
    Step 8: Check Cell Link Should Not Exist
    Step 9: Check Alarm Raised Correctly
    Step 10: Recover Removed Objects
    Step 11: Validate And Activate Plan
    Step 12: Check Relative Seivices Has Restarted Successful After Cell Addition
    Step 13: Check Cell Link Should Exist
    Step 14: Check No Alarm Should Be Raised


Set Up
    Common Test Setup SBTS    alarms_check=${FALSE}    scf_check=${FALSE}
    ${win_index}    SBTS WEM Logon    https://${MPLANE_IP}    skip_error=${True}
    SBTS WEM BackUp Current Configuration    https://${MPLANE_IP}    skip_error=${True}    windows_index=${win_index}
    Status Of RAT Should Be OK
    SBTS WEM Open Alarm Management
    ${alarms}    SBTS WEM Get Alarms On Current Page
    Set Test Variable    ${ALARMS_BEFORE_TEST}    ${alarms}
    ${filter_list}    Create List
    FOR    ${str}    IN    @{IGNORE_ALARM_FILTER_STRING}
        &{filter}    Evaluate    ${str}
        Append To List    ${filter_list}    ${filter}
    END
    Set Test Variable    ${IGNORE_ALARM_FILTER}    ${filter_list}

Tear Down
    Common Test Teardown SBTS
    ${time}    Get Time    epoch
    Run Keyword If Test Failed    Capture Page Screenshot    ${time}.png
    SBTS WEM Download Chrome Console Log
    Run Keyword If Test Failed    SBTS WEM Activate Planed BTS Configuration
    [Teardown]    Close All Browsers

Step ${index}: Find Cell And Cell Mapping For Removal
    LOG    Step ${index}: Find Cell And Cell Mapping For Removal    console=${True}
    ${cell_link_path_list}    SBTS WEM Get Cell Link Path
    ${count}    Get Length    ${cell_link_path_list}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    ${cell_link_path_dic}    Get From List    ${cell_link_path_list}    ${index}
    ${cell}    Get From Dictionary    ${cell_link_path_dic}    cell
    ${ant_list}    Create List
    FOR    ${cell_link_path_dic}    IN    @{cell_link_path_list}
        ${tmpcell}    Get From Dictionary    ${cell_link_path_dic}    cell
        Run Keyword If    '${tmpcell}'=='${cell}'    Append To List    ${ant_list}    ${cell_link_path_dic["ant"]}
    END
    ${cell_list}    Create List
    ${cell_link_list}    Create List
    FOR    ${cell_link_path_dic}    IN    @{cell_link_path_list}
        ${tmpant}    Get From Dictionary    ${cell_link_path_dic}    ant
        ${is_not_contains}    Run Keyword And Return Status    List Should Not Contain Value    ${ant_list}    ${tmpant}
        Continue For Loop If    ${is_not_contains}
        Append To List    ${cell_list}    ${cell_link_path_dic["cell"]}
        Append To List    ${cell_link_list}    ${cell_link_path_dic["ant"]}
    END
    ${cell_list}    Remove Duplicates    ${cell_list}
    ${cell_link_list}    Remove Duplicates    ${cell_link_list}
    Set Test Variable    ${CELL_TO_REMOVE_LIST}    ${cell_list}
    Set Test Variable    ${CELL_LINK_SHOULD_REMOVE_LIST}    ${cell_link_list}

Step ${index}: Remove Cells And Cell Mappings
    LOG    Step ${index}: Remove Cells And Cell Mappings    console=${True}
    ${REMOVED_MO_PATH}    Create List
    FOR    ${cell_name}    IN    @{CELL_TO_REMOVE_LIST}
        ${dic_removed_MO_path}    SBTS WEM Remove Cell By Name    ${cell_name}    ${True}
        Append To List    ${REMOVED_MO_PATH}    ${dic_removed_MO_path}
    END
    Set Test Variable    ${REMOVED_MO_PATH}
    ${list_ANT}    Create List
    FOR    ${cell_link}    IN    @{CELL_LINK_SHOULD_REMOVE_LIST}
        ${ANT}    Set_VSWR_Alarm_Threshold    ${cell_link}
        Continue For Loop If    '${ANT}'==''
        Append To List    ${list_ANT}    ${ANT}
    END
    Set Test Variable    ${LIST_ANT}    ${list_ANT}

Step ${index}: Check Alarm Raised Correctly
    LOG    Step ${index}: Check No Alarm Should Be Raised    console=${True}
    SBTS WEM Open Alarm Management
    ${alarms}    SBTS WEM Get Alarms On Current Page
    Set Test Variable    ${ALALRMS_AFTER_TEST}    ${alarms}
    ${alarms_cleared}    ${alarms_raised}    Compare Alarm List    ${ALARMS_BEFORE_TEST}    ${ALALRMS_AFTER_TEST}    ${IGNORE_ALARM_FILTER}
    ${count}    Get Length    ${alarms_raised}
    Run Keyword If    not ${NEED_RESTART_SBTS}    Should Be Equal As Integers    ${count}    ${0}
    Return From Keyword If    not ${NEED_RESTART_SBTS}
    &{expect_alarm}    Create Dictionary    Alarm ID=7112    Fault ID=2403
    Alarm List Should Contains Special Alarm    ${alarms_raised}    ${expect_alarm}

Step ${index}: Check No Alarm Should Be Raised
    LOG    Step ${index}: Check No Alarm Should Be Raised    console=${True}
    SBTS WEM Open Alarm Management
    ${alarms}    SBTS WEM Get Alarms On Current Page
    Set Test Variable    ${ALALRMS_AFTER_TEST}    ${alarms}
    ${alarms_cleared}    ${alarms_raised}    Compare Alarm List    ${ALARMS_BEFORE_TEST}    ${ALALRMS_AFTER_TEST}    ${IGNORE_ALARM_FILTER}
    ${count}    Get Length    ${alarms_raised}
    Should Be Equal As Integers    ${count}    ${0}

Step ${index}: Check Relative Seivices Has Restarted Successful After Cell ${action}
    LOG    Step ${index}: Check Relative Seivices Has Restarted Successful After Cell ${action}    console=${True}
    ${rat_count}    Get Length    ${RATS_TO_RESET}    #If length of RATS_TO_RESET is zero, it means only one LTE cell has been ${action}
    Run Keyword If    "${rat_count}"=="${0}"    Check All Cells Status During ${action}
    ...    ELSE    Check RATs Has Reseted Successful    ${RATS_TO_RESET}
    [Teardown]    Run Keywords    SBTS WEM Close Dialog After Activation

Step ${index}: Validate And Activate Plan
    LOG    Step ${index}: Validate And Activate Plan    console=${True}
    SBTS WEM Validate Plan
    Should Has No Configuration Error
    SBTS WEM Activate Current BTS Configuration    wait_until_finish=${False}    reset_list=${RATS_TO_RESET}

Step ${index}: Validate And Activate Plan Expect Error
    LOG    Step ${index}: Validate And Activate Plan    console=${True}
    SBTS WEM Validate Plan
    SBTS WEM Activate Current BTS Configuration    forced_activate=${True}    wait_until_finish=${False}    reset_list=${RATS_TO_RESET}

Step ${index}: Check Cell Link Should Exist
    LOG    Step ${index}: Check Cell Link Should Exist    console=${True}
    ${tmp_cell_link_path_list}    SBTS WEM Get Cell Link Path
    ${cell_link_path_list}    Create List
    FOR    ${link_path}    IN    @{tmp_cell_link_path_list}
        Append To List    ${cell_link_path_list}    ${link_path['ant']}
    END
    ${is_exist}    Run Keyword And Return Status    List Should Contain Sub List    ${cell_link_path_list}    ${CELL_LINK_SHOULD_REMOVE_LIST}
    Should Be True    ${is_exist}
    SBTS WEM Check Cell Exist    ${CELL_TO_REMOVE_LIST}

Step ${index}: Check Cell Link Should Not Exist
    LOG    Step ${index}: Check Cell Link Should Not Exist    console=${True}
    ${tmp_cell_link_path_list}    SBTS WEM Get Cell Link Path
    ${cell_link_path_list}    Create List
    FOR    ${link_path}    IN    @{tmp_cell_link_path_list}
        Append To List    ${cell_link_path_list}    ${link_path['ant']}
    END
    ${is_exist}    Run Keyword And Return Status    List Should Contain Sub List    ${cell_link_path_list}    ${CELL_LINK_SHOULD_REMOVE_LIST}
    Should Not Be True    ${is_exist}
    SBTS WEM Check Cell Exist    ${CELL_TO_REMOVE_LIST}    ${False}

Step ${index}: Recover Removed Objects
    LOG    Step ${index}: Recover Removed Objects    console=${True}
    Copy Deleted MO From Backup Plan

Step ${index}: Set Reset Mode
    LOG    Step ${index}: Set Reset Mode    console=${True}
    &{type_dic}    Evaluate    {'LNCEL':'LTE','WNCEL':'WCDMA','GNCEL':'GSM','NRCELL':'NR'}
    ${reset_rat_list}    Create List
    FOR    ${cell}    IN    @{CELL_TO_REMOVE_LIST}
        ${type}    Fetch From Left    ${cell}    -
        ${rat}    Get From Dictionary    ${type_dic}    ${type}
        Append To List    ${reset_rat_list}    ${rat}
    END
    ${reset_rat_list}    Remove Duplicates    ${reset_rat_list}
    Remove Values From List    ${reset_rat_list}    LTE    NR
    Set Test Variable    ${RATS_TO_RESET}    ${reset_rat_list}

Should Has Configuration Error
    ${hardware_error}    SBTS WEM Get Configuration Errors    HE
    ${definition_error}    SBTS WEM Get Configuration Errors    DE
    ${relation_error}    SBTS WEM Get Configuration Errors    RE
    ${count}    Get Length    ${hardware_error}
    Should Be Equal As Integers    ${count}    ${0}
    ${count}    Get Length    ${definition_error}
    Should Be Equal As Integers    ${count}    ${0}
    ${count}    Get Length    ${relation_error}
    Should Be Equal As Integers    ${count}    ${1}
    ${errs}    Get From Dictionary    ${relation_error}    parameter-validation-errors
    ${err_count}    Get Length    ${errs}
    ${ant_count}    Get Length    ${LIST_ANT}
    ${exp_err_count}    Evaluate    ${ant_count}*2
    Should Be Equal As Integers    ${err_count}    ${exp_err_count}
    ${ant_reg_str}    Set Variable
    FOR    ${ant}    IN    @{LIST_ANT}
        ${ant_reg_str}    Set Variable    ${ant_reg_str}|${ant}
    END
    FOR    ${err}    IN    @{errs}
        Should Match Regexp    ${err['Object name']}    MRBTS-\\d+/EQM-\\d+/APEQM-\\d+/(${ant_reg_str})
        ${tmp1}    Set Variable    it is required that there shall exist at least one CHANNEL
        Should Contain    ${err['Error description']}
        ${tmp1} object where antlDN contains DN of this ANTL and direction of that CHANNEL is set to 1 (TX)
    END

Set_VSWR_Alarm_Threshold
    [Arguments]    ${cell_link}
    ${cell_link_obj_list}    Split String    ${cell_link}    /
    ${ANT}    Set Variable    ${cell_link_obj_list[-2]}/${cell_link_obj_list[-1]}
    #${ANT}: RMOD_R-x/ANTL_R-x
    ${filter}    Fetch from right    ${ANT}    /
    ${path}    Fetch from left    ${ANT}    /
    SBTS WEM Select Object On Navigation Panel Under Pramater Editor    ${path}    ${filter}
    SBTS WEM Filt Parameter    form_abbreviation=txCapable
    ${parameters}    SBTS WEM Get Parameters In PE Table
    Clear Element Text    //parameters-editor-table-header//th[@class="pe-abbreviation-cell"]/input
    Return From Keyword If    '${parameters[0]["actual_value"]}'=='false'    ${EMPTY}
    SBTS WEM Filt Parameter    form_abbreviation=configDN
    ${parameters}    SBTS WEM Get Parameters In PE Table
    Clear Element Text    //parameters-editor-table-header//th[@class="pe-abbreviation-cell"]/input
    ${count}    BuiltIn.Get Length    ${parameters}
    Should Be Equal As Integers    ${count}    ${1}
    ${cell_link_obj}    Split String    ${parameters[0]["actual_value"]}    /
    ${ANT}    Set Variable    ${cell_link_obj[-2]}/${cell_link_obj[-1]}
    ${index}    Fetch From Right    ${ANT}    -
    ${remainder}    Evaluate    ${index}%2
    Return From Keyword If    '${remainder}'=='${0}'    ${EMPTY}    #The even number of ANT is probably not configured to TX port.
    #${ANT}: RMOD-y/ANTL-y
    SBTS WEM Modify Parameters In PE Table    ${ANT}    VSWR major alarm threshold    3
    SBTS WEM Modify Parameters In PE Table    ${ANT}    VSWR minor alarm threshold    2
    [Return]    ${ANT}

Copy Deleted MO From Backup Plan
    ${dic_c_type_param}    Create Dictionary
    ...    LNCEL=Local cell resource ID    GNCEL=LCELC Identifier    NRCELL=Local cell resource ID    WNCEL=${EMPTY}
    FOR    ${dic}    IN    @{REMOVED_MO_PATH}
        ${cell}    Get From Dictionary    ${dic}    cell
        ${cellMapping}    Get From Dictionary    ${dic}    cellMapping
        Copy MO From Backup Plan    ${cell}
        ${cell_type}    Set Variable    ${cell.split('/')[-1].split('-')[0]}
        ${param_name}    Get From Dictionary    ${dic_c_type_param}    ${cell_type}
        ${ret}    Run Keyword If    '${cell_type}'!='WNCEL'    SBTS WEM Modify Parameters In PE Table    ${cell}    ${param_name}
        ...    ${cellMapping.split('/')[-1].split('-')[1]}
        Should Be True    '${ret}'=='${None}' or '${ret}'=='${True}'
        ${ret}    Run Keyword If    '${cell_type}'=='WNCEL'    SBTS WEM Modify Parameters In PE Table    ${cell}    LCELW object reference
        ...    ${cellMapping}
        Should Be True    '${ret}'=='${None}' or '${ret}'=='${True}'
        Run Keyword If    '${cell_type}'=='WNCEL'
        ...    SBTS WEM Set New Add Sub-Item In PE    WNCELG-    Local cell identifier list    ${cell.split('/')[-1].split('-')[1]}
        Copy MO From Backup Plan    ${cellMapping}
        Continue For Loop If    '${cell_type}'!='NRCELL'
        ${cell_group}    Get From Dictionary    ${dic}    cellGroup
        Copy MO From Backup Plan    ${cell_group}
        SBTS WEM Set New Add Sub-Item In PE    NRDU-    Reference to cell group    ${cell_group.split('/')[-1].split('-')[1]}
    END

Check All Cells Status During Deletion
    ${changed_of_cells}    ${is_finished}    Get Cells State Duration    300    1
    Should Be True    ${is_finished}
    ${cells}    Create List
    FOR    ${dic}    IN    @{REMOVED_MO_PATH}
        ${cell}    Get From Dictionary    ${dic}    cell
        Append To List    ${cells}    ${cell}
    END
    FOR    ${changes}    IN    @{changed_of_cells}
        Remove From Dictionary    ${changes}    @{cells}
        Should Be Empty    ${changes}
    END
    ${all_cells}    ${status}    Get Current Name And Status Of All Cells
    ${all_cells_name}    Get Dictionary Keys    ${all_cells}
    ${is_contain}    Run Keyword And Return Status    List Should Contain Sub List    ${all_cells_name}    ${cells}
    Should Not Be True    ${is_contain}

Check All Cells Status During Addition
    ${changed_of_cells}    ${is_finished}    Get Cells State Duration    300    1
    Should Be True    ${is_finished}
    ${cells}    Create List
    FOR    ${dic}    IN    @{REMOVED_MO_PATH}
        ${cell}    Get From Dictionary    ${dic}    cell
        Append To List    ${cells}    ${cell}
    END
    FOR    ${changes}    IN    @{changed_of_cells}
        Remove From Dictionary    ${changes}    @{cells}
        Should Be Empty    ${changes}
    END
    ${all_cells}    ${status}    Get Current Name And Status Of All Cells
    ${all_cells_name}    Get Dictionary Keys    ${all_cells}
    List Should Contain Sub List    ${all_cells_name}    ${cells}

Copy MO From Backup Plan
    [Arguments]    ${MO}
    ${class}    Set Variable    ${MO.split('/')[-1].split('-')[0]}
    ${object_id}    Set Variable    ${MO.split('/')[-1].split('-')[1]}
    ${parent_path}    Set Variable    ${MO.split('/${class}')[0]}
    ${parent_name}    Set Variable    ${parent_path.split('/')[-1]}
    ${param1}    Create List    Object class:    selectedlist    ${class}
    ${param2}    Create List    Load default values:    checkbox    ${False}
    ${param3}    Create List    Plan to copy from:    selectedlist    CM_TA_BACKUP
    ${param4}    Create List    Copy from:    selectedlist    ${MO}
    ${param5}    Create List    Including subobjects:    checkbox    ${True}
    ${param6}    Create List    Id:    textbox    ${object_id}
    ${params}    Create List    ${param1}    ${param2}    ${param3}    ${param4}    ${param5}
    ...    ${param6}
    ${created_object_path}    SBTS WEM Add Object On Navigation Panell Under Pramater Editor    ${parent_path}    ${parent_name}    ${params}
