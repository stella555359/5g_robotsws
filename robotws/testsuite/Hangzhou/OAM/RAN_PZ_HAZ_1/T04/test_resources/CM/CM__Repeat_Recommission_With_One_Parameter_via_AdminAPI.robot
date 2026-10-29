*** Settings ***
Documentation       Test case for EDA action: CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${TEST_DATA_FILE}
#...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/LTE_Cell_Locking/CM_LTE_Cell_Locking_para.yaml
#@{SELECTED_TYPE}    LTE_CELL_LOCK
...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRObject_Locking/CM_NR_Locking_para.yaml
@{SELECTED_TYPE}    NR_CELL_LOCK
#...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/LTERatReset/CM_LTERatReset_para.yaml
#@{SELECTED_TYPE}    LTE_RAT_RESET
#...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/NRRat_Reset/CM_NRRat_Reset_para.yaml
#@{SELECTED_TYPE}    NR_RAT_RESET
#...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/SiteReset/CM_SiteReset_para.yaml
#@{SELECTED_TYPE}    SBTS_SITE_RESET
${REPEAT_TIME}    100

*** Keywords ***
CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    [Documentation]    [CASE MRT]: CM__Repeat_Recommission_With_One_Parameter_via_AdminAPI
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    Repeat to delta commission by admin api: randomly select one service impact type parameter
    ...    Pass criteria: parameter be updated, bts onair with no fault and error.
    ...
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.08.2025 - Xu Yuyan - New case

    Set Tags    CM    AUTHOR-yuyan.xu@nokia-sbell.com     OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Select Parameter
    Step 2: Repeat Recommission Via Admin

Step ${index}: Select Parameter
    Log To Console    Step ${index}: Select Parameter
    ${plan_info}    ${plan_info_ui}    ${expect_status}    Random Select TestData Of Trigger Action Parameters From Json
    ...    ${TEST_DATA_FILE}    ${SELECTED_TYPE}
    Set Test Variable    ${plan_info}
    Set Test Variable    ${plan_info_ui}
    Set Test Variable    ${expect_status}
    Log To Console    ${plan_info_ui}
    ${key}    Get Dictionary Keys    ${plan_info_ui['parameter']}
    ${param_name}    Set Variable    ${key[0]}
    ${initial_value}    Get Parameter Value From WebEM
    ...    ${plan_info_ui['scf_distName']}    ${param_name}
    ${param_value_plan}    Set Variable    ${plan_info_ui['parameter']['${param_name}']}
    Set Test Variable    ${initial_value}
    Set Test Variable    ${param_value_plan}
    Set Test Variable    ${param_name}

Step ${index}: Repeat Recommission Via Admin
    Log To Console    Step ${index}: Repeat Recommission Via Admin
    FOR    ${index}    IN RANGE    1    ${${REPEAT_TIME}+1}
        Log To Console    Repeat Time: ${index}
        ${current_value}    Get Parameter Value From WebEM
        ...    ${plan_info_ui['scf_distName']}    ${param_name}
        ${value_to_set}    Set Variable If    "${current_value}"=="${initial_value}"    ${param_value_plan}    ${initial_value}
        coam.perform_parameter_recommissioning    ${plan_info_ui['scf_distName']}   ${param_name}    update    ${value_to_set}    timeout=600
        ${parameter}    Create Dictionary    ${param_name}=${value_to_set}
        Wait Until Keyword Succeeds    20min    15s    Check SBTS SMOD RMOD Cells Alarms
        Check WebEM After Modify Parameters    ${plan_info_ui['scf_distName']}    &{parameter}
        ${need_restart}    Evaluate    ${index}%${20}==0
        Run Keyword If     ${need_restart}    Restart Admin
        ${need_restart}    Evaluate    ${index}%${5}==0
        Run Keyword If     ${need_restart}    Restart Infomodel And Syslog
    END

Restart Admin
   Run Keyword And Continue On Failure    coam.Teardown Admin
   Run Keyword And Continue On Failure    Start Admin    bts_host=${SMOD1['TRS_IP']}

Restart Infomodel And Syslog
    Run Keyword And Continue On Failure    Teardown All Aliases For Syslog
    Run Keyword And Continue On Failure    Teardown All Aliases For Infomodel
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    3x    60s    Start Infomodel
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    3x    60s    Start syslog on SMOD1
    Run Keyword If  ${SMOD2_exists}
    ...    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    3x    60s    Start syslog on SMOD2