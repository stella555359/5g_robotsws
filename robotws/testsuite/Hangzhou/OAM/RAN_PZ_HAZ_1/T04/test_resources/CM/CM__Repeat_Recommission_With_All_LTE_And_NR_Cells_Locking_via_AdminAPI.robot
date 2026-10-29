*** Settings ***
Documentation       Test case for: CM__Repeat_Recommission_With_All_LTE_And_NR_Cells_Locking_via_AdminAPI
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${TEST_DATA_FILE}
...    /home/ute/testline_configuration/${TESTLINE_NAME}/testdata/PremeterModifyTriggerAction/Multi/test_data.yaml
@{SELECTED_TYPE}    LTE_CELL_LOCK    NR_CELL_LOCK
${REPEAT_TIME}    100


*** Keywords ***
CM__Repeat_Recommission_With_All_LTE_And_NR_Cells_Locking_via_AdminAPI
    [Documentation]    [CASE MRT]: CM__Repeat_Recommission_With_All_LTE_And_NR_Cells_Locking_via_AdminAPI
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...
    ...    Repeat to delta commission by admin api: randomly select LTE and NR cell locking parameters for all cells
    ...    Pass criteria: parameter be updated, bts onair with no fault and error.
    ...
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 10.10.2025 - Xu Yuyan - New case

    Set Tags    CM    AUTHOR-yuyan.xu@nokia-sbell.com     OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Repeat Recommission Via Admin

Step ${index}: Repeat Recommission Via Admin
    Log To Console    Step ${index}: Repeat Recommission Via Admin
    FOR    ${index}    IN RANGE    1    ${${REPEAT_TIME}+1}
        Log To Console    Repeat Time: ${index}
        ${BTS_scf}    Admin Collect scf.xml with timestamp TAF    folder_path=${BTSFiles}
        ${expect_status}    ${list_param_for_create_plan}    Get Parameters For NetAct Plan Due To Json File
        ...    ${TEST_DATA_FILE}    ${SELECTED_TYPE}    ${BTS_scf}
        ${time}    Get Time    epoch
        coam.create_delta    delta_id=${mrbts_id}_${time}
        FOR    ${param}    IN    @{list_param_for_create_plan}
            LOG Dictionary    ${param['parameters']}
            coam.append_managed_object_to_delta    ${param['mo_id']}    update    ${mrbts_id}_${time}
            ${keys}    Get Dictionary Keys    ${param['parameters']}
            coam.append_parameter_update_to_delta    ${param['mo_id']}
            ...    ${keys[0]}    ${param['parameters']['${keys[0]}']}    ${MRBTS_ID}_${time}
        END
        ${delta_json}    coam.get_delta    delta_id=${mrbts_id}_${time}
        ${result}    coam.perform_delta_recommissioning    ${delta_json}
        Wait Until Keyword Succeeds    20min    15s    Check SBTS SMOD RMOD Cells Alarms
        FOR    ${param}    IN    @{list_param_for_create_plan}
            Check WebEM After Modify Parameters    ${param['mo_id']}    &{param['parameters']}
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