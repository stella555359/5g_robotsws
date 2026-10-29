*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${CELL_NAME}      ${EMPTY}
${ALARMS_BEFORE_TEST}    ${EMPTY}
${ALALRMS_AFTER_TEST}    ${EMPTY}
${CELL_MAPPING_OBJECT_PATH}    ${EMPTY}
${PARAMS_BACKUP}    ${EMPTY}
@{IGNORE_ALARM_FILTER_STRING}    {'Fault ID':'61649'}    { 'Fault ID':'6286'}    {'Fault ID':'6450'}    { 'Fault ID':'61524'}
...               { 'Fault ID':'61074'}    { 'Fault ID':'4655'}    { 'Fault ID':'61652'}
...               { 'Fault ID':'4654'}    {'Fault ID':'2403','Alarm ID': '7115'}    {'Fault ID':'2403','Alarm ID': '7112'}
${FLAG}           ${False}


*** Keywords ***
CM__GSM_Cell_Addition_And_Deletion_Via_Parameter_Editor
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   - Source case:CRT_021_Automated__CM__GSM_Cell_Addition_And_Deletion_Via_Parameter_Editor.robot
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.05.2023 - Commit to robotws

    Set Tags    CM    UI    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Delete One GSM Cell
    Step 2: Validate And Activate Plan
    Step 3: Check GSM Rat Has Restarted Successful
    Step 4: Check Cell Should Not Be Exist
    Step 5: Check Alarm Should Be Raised
    Step 6: Recovery GSM Cell
    Step 7: Validate And Activate Plan
    Step 8: Check GSM Rat Has Restarted Successful
    Step 9: Check Cell Should Be Exist
    Step 10: Check No Alarm Should Be Raised

Set Up
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
    Common Test Setup SBTS    scf_check=${FALSE}

TearDown
    ${time}    Get Time    epoch
    Run Keyword If Test Failed    Capture Page Screenshot    ${time}.png
    Common Test Teardown SBTS    collect_snapshot=always
    SBTS WEM Download Chrome Console Log
    Run Keyword If    ${FLAG}    SBTS WEM Activate Planed BTS Configuration
    [Teardown]    Close All Browsers

Remove One GSM Cell By PE
    ${cells}    SBTS WEM Get Cells Name And Path    GSM
    ${cell_names}    Get Dictionary Keys    ${cells}
    ${count}    Get Length    ${cell_names}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    Set Test Variable    ${CELL_NAME}    ${cells['${cell_names[${index}]}']}
    SBTS WEM Remove Object On Navigation Panel Under Pramater Editor    ${CELL_NAME}    ${CELL_NAME.split('/')[-1]}
    ${cell_mappings}    SBTS WEM Filt Object On Navigation Panel Under Pramater Editor    LCELC-
    ${mapping_object_paths}    Get Dictionary Keys    ${cell_mappings}
    Sort List    ${mapping_object_paths}
    Set Test Variable    ${CELL_MAPPING_OBJECT_PATH}    ${mapping_object_paths[${index}]}
    ${mapping_name}    Fetch From Right    ${CELL_MAPPING_OBJECT_PATH}    /
    SBTS WEM Remove Object On Navigation Panel Under Pramater Editor    ${CELL_MAPPING_OBJECT_PATH}    ${mapping_name}

Step ${index}: Delete One GSM Cell
    LOG    Step ${index}: Delete One GSM Cell    console=${True}
    SBTS WEM Expand Configuration Tree On Navigation Panel Under Pramater Editor
    Remove One GSM Cell By PE

Step ${index}: Check GSM Rat Has Restarted Successful
    LOG    Step ${index}: Check GSM Rat Has Restarted Successful    console=${True}
    ${Reset_RATs}    Create List    GSM
    Check RATs Has Reseted Successful    ${Reset_RATs}
    Wait Until All Cells Onair
    ${tmp}    Evaluate    not ${FLAG}
    Set Suite Variable    ${FLAG}    ${tmp}
    [Teardown]    Run Keywords    SBTS WEM Close Dialog After Activation

Step ${index}: Check Alarm Should Be Raised
    LOG    Step ${index}: Check Alarm Should Be Raised    console=${True}
    &{expect_alarm}    Create Dictionary    Alarm ID=7112    Fault ID=2403
    ${alarms}    SBTS WEM Wait Until Alarm Raised    ${expect_alarm}
    Set Test Variable    ${ALALRMS_AFTER_TEST}    ${alarms}
    ${tmp_IGNORE_ALARM_FILTER}    Copy List    ${IGNORE_ALARM_FILTER}    ${True}
    Append To List    ${tmp_IGNORE_ALARM_FILTER}    ${expect_alarm}
    ${alarms_cleared}    ${alarms_raised}    Compare Alarm List    ${ALARMS_BEFORE_TEST}    ${ALALRMS_AFTER_TEST}    ${tmp_IGNORE_ALARM_FILTER}
    ${count}    Get Length    ${alarms_raised}
    Should Be Equal As Integers    ${count}    ${0}

Step ${index}: Validate And Activate Plan
    LOG    Step ${index}: Validate And Activate Plan    console=${True}
    SBTS WEM Validate Plan
    Should Only Has Sector Configuration Error Or Not
    ${Reset_RATs}    Create List    GSM
    SBTS WEM Activate Current BTS Configuration    wait_until_finish=${False}    reset_list=${Reset_RATs}

Step ${index}: Check No Alarm Should Be Raised
    LOG    Step ${index}: Check No Alarm Should Be Raised    console=${True}
    SBTS WEM Open Alarm Management
    ${alarms}    SBTS WEM Get Alarms On Current Page
    Set Test Variable    ${ALALRMS_AFTER_TEST}    ${alarms}
    ${alarms_cleared}    ${alarms_raised}    Compare Alarm List    ${ALARMS_BEFORE_TEST}    ${ALALRMS_AFTER_TEST}    ${IGNORE_ALARM_FILTER}
    ${count}    Get Length    ${alarms_raised}
    Should Be Equal As Integers    ${count}    ${0}

Step ${index}: Check Cell Should Be Exist
    LOG    Step ${index}: Check Cell Should Be Exist    console=${True}
    SBTS WEM Expand Configuration Tree On Navigation Panel Under Pramater Editor
    ${cells}    SBTS WEM Get Cells Name And Path    GSM
    Dictionary Should Contain Key    ${cells}    ${CELL_NAME.split('/')[-1]}
    ${tmp}    Evaluate    not ${FLAG}
    Set Test Variable    ${FLAG}    ${tmp}

Step ${index}: Check Cell Should Not Be Exist
    LOG    Step ${index}: Check Cell Should Not Be Exist    console=${True}
    SBTS WEM Expand Configuration Tree On Navigation Panel Under Pramater Editor
    ${cells}    SBTS WEM Get Cells Name And Path    GSM
    Dictionary Should Not Contain Key    ${cells}    ${CELL_NAME.split('/')[-1]}

Step ${index}: Recovery GSM Cell
    LOG    Step ${index}: Recover Removed Objects    console=${True}
    FOR    ${MO}    IN    ${CELL_NAME}    ${CELL_MAPPING_OBJECT_PATH}
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
        ${params}    Create List    ${param1}    ${param2}    ${param3}    ${param4}
        ...    ${param5}    ${param6}
        ${created_object_path}    SBTS WEM Add Object On Navigation Panell Under Pramater Editor    ${parent_path}    ${parent_name}    ${params}
    END
    SBTS WEM Modify Parameters In PE Table    ${CELL_NAME}    LCELC Identifier    ${CELL_NAME.split('-')[-1].strip()}