*** Settings ***
Documentation       Test case for EDA action: CM__Repeat_Recommission_With_One_Set_Different_Impact_Parameter_via_AdminAPI
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${TEST_DATA_FILE}
...   /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/Different_Impact/CM_Different_Impact_para.yaml
@{SELECTED_TYPE}    Different_Impact
${REPEAT_TIME}    100

*** Keywords ***
CM__Repeat_Recommission_With_One_Set_Different_Impact_Parameter_via_AdminAPI
    [Documentation]    [CASE MRT]: CM__Repeat_Recommission_With_One_Set_Different_Impact_Parameter_via_AdminAPI
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    Repeat to delta commission by admin api: randomly select one set different service impact parameter
    ...    Pass criteria: parameter be updated, bts onair with no fault and error.
    ...
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 04.08.2025 - Xu Yuyan - New case

    Set Tags    CM    AUTHOR-yuyan.xu@nokia-sbell.com     OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Select One Set Parameters
    Step 2: Repeat Recommission Via Admin

Step ${index}: Select One Set Parameters
    Log To Console    Step ${index}: Select One Set Parameters
    ${Param_plan_dic_list}    Select One Set TestData Of Trigger Action Parameters From Json    ${TEST_DATA_FILE}    ${SELECTED_TYPE}
    Log    ${Param_plan_dic_list}
    Set Test Variable    ${Param_plan_dic_list}
    FOR    ${Param_plan_dic}    IN    @{Param_plan_dic_list}
        ${key}    Get Dictionary Keys    ${Param_plan_dic["plan_info_ui"]['parameter']}
        ${param_name}    Set Variable    ${key[0]}
        ${initial_value}    Get Parameter Value From WebEM
        ...    ${Param_plan_dic["plan_info_ui"]['scf_distName']}    ${param_name}
        ${value_list}    Create List    ${Param_plan_dic["plan_info_ui"]["parameter"]["${param_name}"]}     ${initial_value}
        Set To Dictionary    ${Param_plan_dic["plan_info_ui"]["parameter"]}    ${param_name}=${value_list}
    END

Step ${index}: Repeat Recommission Via Admin
    Log To Console    Step ${index}: Repeat Recommission Via Admin
    FOR    ${index}    IN RANGE    1    ${${REPEAT_TIME}+1}
        Log To Console    Repeat Time: ${index}
        ${mo_list}    Create List
        ${time}    Get Time    epoch
        coam.create_delta    delta_id=recommission_${time}
        FOR    ${Param_plan_dic}    IN    @{Param_plan_dic_list}
            ${key}    Get Dictionary Keys    ${Param_plan_dic["plan_info_ui"]['parameter']}
            ${param_name}    Set Variable    ${key[0]}
            ${current_value}    Get Parameter Value From WebEM
            ...    ${Param_plan_dic["plan_info_ui"]['scf_distName']}    ${param_name}
            ${value_to_set}    Set Variable If    "${current_value}"=="${Param_plan_dic["plan_info_ui"]["parameter"]["${param_name}"][0]}"
            ...    ${Param_plan_dic["plan_info_ui"]["parameter"]["${param_name}"][1]}
            ...    ${Param_plan_dic["plan_info_ui"]["parameter"]["${param_name}"][0]}
            Set To Dictionary    ${Param_plan_dic["plan_info_ui"]["parameter"]}    value_to_set=${value_to_set}
            ${mo_not_existed}    Run Keyword And Return Status
            ...    List Should Not Contain Value    ${mo_list}    ${Param_plan_dic["plan_info_ui"]['scf_distName']}
            Run Keyword If    ${mo_not_existed}    Run Keywords
            ...    coam.append_managed_object_to_delta    ${Param_plan_dic["plan_info_ui"]['scf_distName']}    update    recommission_${time}
            ...    AND    Append To List    ${mo_list}    ${Param_plan_dic["plan_info_ui"]['scf_distName']}
            coam.append_parameter_update_to_delta    ${Param_plan_dic["plan_info_ui"]['scf_distName']}
            ...    ${param_name}    ${value_to_set}    recommission_${time}
        END
        ${delta_json}    coam.get_delta    delta_id=recommission_${time}
        ${result}    coam.perform_delta_recommissioning    ${delta_json}
        Wait Until Keyword Succeeds    20min    15s    Check SBTS SMOD RMOD Cells Alarms
        FOR    ${Param_plan_dic}    IN    @{Param_plan_dic_list}
            ${key}    Get Dictionary Keys    ${Param_plan_dic["plan_info_ui"]['parameter']}
            ${param_name}    Set Variable    ${key[0]}
            ${parameter}    Create Dictionary    ${param_name}=${Param_plan_dic["plan_info_ui"]["parameter"]["value_to_set"]}
            Check WebEM After Modify Parameters    ${Param_plan_dic["plan_info_ui"]['scf_distName']}    &{parameter}
        END
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