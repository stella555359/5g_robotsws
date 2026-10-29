*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Library           XML    use_lxml=True
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${ALARMS_BEFORE_TEST}    ${EMPTY}
${ALALRMS_AFTER_TEST}    ${EMPTY}
${PARAM_FILE_PATH}    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/Local_Cases/NROnline
#TestDataSet/PremeterModifyTriggerAction/NROnline
${TEST_DATA}      ${EMPTY}
${PARAM_FILE_LIST}    ${EMPTY}
${ACTION_OBJECT_LIST}    ${EMPTY}
${CUR_FILE_NAME}    ${EMPTY}
@{PARAMS_BACKUP_LIST}
@{Blocked_Cells}


*** Keywords ***
CM__RP002956_5G_Online_Recommission_Via_Parameter_Editor
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   - Source case:Automated__CM__Online_Recommission_Via_Parameter_Editor_RP002956_5G.robot
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.05.2023 - Commit to robotws

    Set Tags    CM    UI    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    #Set Library Search Order    Selenium2Library
    #Modify Resource Search Order    CM__Online_Recommission_Via_Parameter_Editor_RP002956_5G
    #Set Library Search Order    CM__Online_Recommission_Via_Parameter_Editor_RP002956_5G
    LOG    ${TEST_NAME} start.    console=${True}
    ${file_list}    OperatingSystem.List Files In Directory    ${PARAM_FILE_PATH}
    Set Suite Variable    ${PARAM_FILE_LIST}    ${file_list}
    FOR    ${name}    IN    @{PARAM_FILE_LIST}
        Set Suite Variable    ${CUR_FILE_NAME}    ${name}
        Run Keyword And Continue On Failure    Objects_Change_Status_After_Delta_Recommissioning_Via_Parameter_Editor
    END

Step ${index}: LogOn And Check SBTS Status
    LOG    Step ${index}: LogOn And Check SBTS Status    console=${True}
    SBTS WEM Re-Logon
    Status Of RAT Should Be OK
    SBTS WEM Check No Cells Are Blocked
    SBTS WEM Open Alarm Management
    ${alarms}    SBTS WEM Get Alarms On Current Page
    Set Suite Variable    ${ALARMS_BEFORE_TEST}    ${alarms}
    @{PARAMS_BACKUP_LIST}    Create List

Step ${index}: Set Parameters
    LOG    Step ${index}: Set Parameters    console=${True}
    #${param_list} example:{ \ "Parameters":[ \ { \ \ \ "MO":"MRBTS/LNBTS/LNCEL", \ \ \ "operation": "modify", \ \ \
    #...    "parameters":[{"Activate flexible duplexing gap":["true","false"]}] \ }], \ "Actions": \ { \ \ \ "MO":"", \ \ \ "expect":"lock" \ } }
    ${tmp_test_data}    SBTS WEM Load Json File    ${PARAM_FILE_PATH}/${CUR_FILE_NAME}
    @{test_data_list}    Convert To List    ${tmp_test_data}
    ${count}    Get Length    ${test_data_list}
    ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
    Set Suite Variable    ${TEST_DATA}    @{test_data_list}[${index}]
    LOG    \nTEST_DATA is :\n${TEST_DATA}    console=${True}
    ${param_list}    Set Variable    ${TEST_DATA["Parameters"]}
    Set Parameter Of List    ${param_list}
    #${param_list} example :[ \ { \ \ \ "MO":"MRBTS/LNBTS/LNCEL", \ \ \ "operation": "modify", \ \ \
    #...    "parameters":[{"Activate flexible duplexing gap":["true","false"]}] \ }]

Step ${index}: Get Action Objects
    LOG    Step ${index}: Get Action Objects    console=${True}
    ${tmp_list}    Get Objects By Condition    ${TEST_DATA["Actions"]["MO"]}
    Set Suite Variable    ${ACTION_OBJECT_LIST}    ${tmp_list}
    ${special_type}    Create List    WCDMA    LTE    GSM    SBTS    NR
    ${not_empty}    Run Keyword And Return Status    Should Not Be Empty    ${tmp_list}
    ${is_special}    Run Keyword And Return Status    List Should Contain Sub List    ${special_type}    ${tmp_list}
    Return From Keyword IF    ${is_special} and ${not_empty}
    ${modified_objs}    Get Dictionary Keys    @{PARAMS_BACKUP_LIST}[0]
    ${tmp_obj}    Fetch From Right    ${modified_objs[0]}    /
    ${modified_obj}    Fetch From Left    ${modified_objs[0]}    /${tmp_obj}
    ${special_type}    Create List    CELL
    ${is_special}    Run Keyword And Return Status    List Should Contain Sub List    ${special_type}    ${tmp_list}
    ${modified_obj}    Set Variable If    ${is_special} and ${not_empty}    ${modified_obj}    ${modified_objs[0]}
    ${tmp_list}    Create List    ${modified_obj}
    Set Suite Variable    ${ACTION_OBJECT_LIST}    ${tmp_list}

Step ${index}: Validata And Activate Plan
    LOG    Step ${index}: Validata And Activate Plan    console=${True}
    SBTS WEM Validate Plan
    ${is_bts}    Run Keyword And Return Status    Should Contain    ${ACTION_OBJECT_LIST}    SBTS
    ${reset_list}    Set Variable If    '${TEST_DATA["Actions"]["expect"]}'=='reset'    ${ACTION_OBJECT_LIST}    ${None}
    SBTS WEM Activate Current BTS Configuration    forced_activate=${True}    wait_until_finish=${False}    reset_list=${reset_list}

Step ${index}: Check Action
    LOG    Step ${index}: Check Action    console=${True}
    ${is_bts}    Run Keyword And Return Status    Should Contain    ${ACTION_OBJECT_LIST}    SBTS
    Run Keyword If    '${is_bts}'=='True' and '${TEST_DATA["Actions"]["expect"]}'=='reset'    Check SBTS Has Restarted Successful
    Run Keyword And Return If    '${is_bts}'=='True' and '${TEST_DATA["Actions"]["expect"]}'=='reset'
    ...    Set Suite Variable    ${NEED_SCREEN_SHOT}    ${False}
    ${rat_type}    Create List    WCDMA    LTE    GSM    NR
    ${is_rat}    Run Keyword And Return Status    Should Contain    ${rat_type}    ${ACTION_OBJECT_LIST[0]}
    Run Keyword If    '${is_rat}'=='True' and '${TEST_DATA["Actions"]["expect"]}'=='reset'
    ...    Check RATs Has Reseted Successful    ${ACTION_OBJECT_LIST}    660
    Run Keyword And Return If    '${is_rat}'=='True' and '${TEST_DATA["Actions"]["expect"]}'=='reset'
    ...    Set Suite Variable    ${NEED_SCREEN_SHOT}    ${False}
    Run Keyword If    '${is_rat}'=='True' and '${TEST_DATA["Actions"]["expect"]}'=='lock'
    ...    Check RATs Has Reseted Successful    ${ACTION_OBJECT_LIST}
    Run Keyword And Return If    '${is_rat}'=='True' and '${TEST_DATA["Actions"]["expect"]}'=='lock'
    ...    Set Suite Variable    ${NEED_SCREEN_SHOT}    ${False}
    Run Keyword If    '${TEST_DATA["Actions"]["expect"]}'=='lock'    Check Cells States Has Changed In Time    ${ACTION_OBJECT_LIST}    180
    Run Keyword If    '${TEST_DATA["Actions"]["expect"]}'==''    Check No Cells States Has Changed In Time    300
    Set Suite Variable    ${NEED_SCREEN_SHOT}    ${False}
    [Teardown]    Run Keywords    SBTS WEM Close Dialog After Activation    AND    Wait Until All Cells Onair


Set Parameter Of List
    [Arguments]    ${param_list}
    # ${param} like:{ \ "MO":"MRBTS/LNBTS/LNCEL", \ \ \ "operation": "modify", \ \ \
    # "parameters":[{"Activate flexible duplexing gap":["true","false"]}] \ }
    FOR    ${param}    IN    @{param_list}
        ${modify_object_condition}    Set Variable    ${param["MO"]}
        ${modify_object_list}    Get Objects By Condition    ${modify_object_condition}
        ${count}    Get Length    ${modify_object_list}
        ${index}    Evaluate    random.randint(0,${count-1})    modules=random, sys
        ${target_object}    Get From List    ${modify_object_list}    ${index}
        ${filter}    Fetch From Right    ${target_object}    /
        SBTS WEM Select Object On Navigation Panel Under Pramater Editor    ${target_object}    ${filter}
        ${parameter_list}    Set Variable    ${param["parameters"]}
        #${parameter_list} like:[{"Activate flexible duplexing gap":["true","false"]}]
        ${back_param}    SBTS WEM Set Parameters Of One Object    ${target_object}    ${parameter_list}
        Append To List    ${PARAMS_BACKUP_LIST}    ${back_param}
    END

Recover Parameters
    ${count}    Get Length    ${PARAMS_BACKUP_LIST}
    Return From Keyword If    '${count}'=='${0}'    ${True}
    FOR    ${obj_param}    IN    @{PARAMS_BACKUP_LIST}
        ${obj_list}    Get Dictionary Keys    ${obj_param}
        ${param_list}    Get From Dictionary    ${obj_param}    ${obj_list[0]}
        ${modified_param}    SBTS WEM Set Parameters Of One Object    ${obj_list[0]}    ${param_list}
        ${tmp_param}    Get From Dictionary    ${modified_param}    ${obj_list[0]}
        ${count1}    Get Length    ${tmp_param}
        ${count2}    Get Length    ${param_list}
        Should Be Equal As Integers    ${count1}    ${count2}
        Remove Values From List    ${PARAMS_BACKUP_LIST}    ${obj_param}
    END
    SBTS WEM Validate Plan
    ${reset_list}    Set Variable If    '${TEST_DATA["Actions"]["expect"]}'=='reset'    ${ACTION_OBJECT_LIST}    ${None}
    ${is_pass}    ${msg}    Run Keyword And Ignore Error    SBTS WEM Activate Current BTS Configuration
    ...    forced_activate=${True}    wait_until_finish=${False}    reset_list=${reset_list}
    ${is_activated}    Set Variable If    "${is_pass}"=="PASS"    ${True}    ${False}
    Return From Keyword If    not ${is_activated}    ${is_activated}
    Step Recover: Check Action
    [Return]    ${is_activated}

Objects_Change_Status_After_Delta_Recommissioning_Via_Parameter_Editor
    Step 1: LogOn And Check SBTS Status
    Step 2: Set Parameters
    Step 3: Get Action Objects
    Step 4: Validata And Activate Plan
    Step 5: Check Action
    [Teardown]    Tear Down

Tear Down
    LOG    Step: Tear Down    console=${True}
    ${time}    Get Time    epoch
    Run Keyword If    ${NEED_SCREEN_SHOT}    Capture Page Screenshot    ${time}.png
    ${is_recovered}    Recover ENV
    Set Test Variable    ${IS_RECOVERED}    ${is_recovered}
    SBTS WEM Download Chrome Console Log

Set Up
    Common Test Setup SBTS    scf_check=${FALSE}
    Set Library Search Order    Selenium2Library
    Set Suite Variable    ${NEED_SCREEN_SHOT}    ${True}
    SBTS WEM BackUp Current Configuration    https://${MPLANE_IP}    skip_error=${True}

Case TearDown
    Common Test Teardown SBTS
    Run Keyword If    not ${IS_RECOVERED}    SBTS WEM Activate Planed BTS Configuration
    Close All Browsers

Recover ENV
    ${is_recovered}    Recover Parameters
    [Return]    ${is_recovered}


