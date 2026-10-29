*** Settings ***
Documentation    Suite description
...    Author:
...    Maintainer:
Resource    ../common_setup.robot
Resource    ../test_fv.robot

*** Keywords ***
Stability Suite Precondition
    Create BTSCONFIG Dictionary
    ${status}    Run Keyword And Return Status    OperatingSystem.File Should Exist
    ...    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1/TestCase/${TL_NAME}/variables.robot
    Run Keyword If    ${status}    Import Resource
    ...    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1/TestCase/${TL_NAME}/variables.robot
    Import Variables    testsuite/Hangzhou/SISO/RAN_PZ_HAZ_1/TestCase/${TL_NAME}/env.py
    Set Suite Logs Dir Path
    ${GLO_ADMIN_ALLOWED_ALARM}    Create List    @{ALLOWED_FAULT}    @{ADDITIONAL_ADMIN_ALLOWED_ALARMS}
    Set Suite Variable    ${GLO_ADMIN_ALLOWED_ALARM}

    ${GLO_ADMIN_HISTORY_ALLOWED_ALARM}     Create List
    Set Suite Variable    ${GLO_ADMIN_HISTORY_ALLOWED_ALARM}

    Set Suite Variable    ${SW_BUILDS_DIR_PATH}    ${SW_BUILDS_DIR_PATH}cloud/
    Cleanup Environment
    Log Variables

    ${supported_call}    Run Keyword And Return Status    Variable Should Exist    ${tl_config.SUPPORTED_CALL}
    ${IS_SUPPORTED_CALL}    Set Variable If    ${supported_call}     ${tl_config.SUPPORTED_CALL}     ${True}
    Set Suite Variable    ${IS_SUPPORTED_CALL}
    Run keyword And Ignore Error    Copy File    ${CURDIR}/tools/arti_netrc    /home/ute/.netrc
    Set Suite Variable    ${NEED_UPDATE}    ${True}

Stability Testcase Basic Precondition
    [Arguments]    ${case_name}
    ${status}    Run Keyword And Return Status    Variable Should Exist    ${config_id}
    ${config_id}    Set Variable If    ${status}    ${config_id}    ${EMPTY}
    Close Multi Node Process
    Set Test Variable    ${CASE_NAME}    ${case_name}
    Set TC Dir Path
    ${sm_sn_list}    Get Dictionary Keys    ${BTS_CONFIG['FSM']}
    PDU Turn On All Devices From Serial Number List    ${sm_sn_list}    ${BTS_CONFIG}    FSM
    Create Nodes Parameters Init    ${config_id}    force=False
    Logging Multinode Start    ${TEST_LOGS_DIR_PATH}/setup
    ${out_SAS_SIM_config}    Run Keyword And Return Status    Variable Should Exist    ${tl_config.SAS_SIM}
    ${out_need_SAS_SIM}    Set Variable If     ${out_SAS_SIM_config}      ${tl_config.SAS_SIM}    False
    Run Keyword If     "${out_need_SAS_SIM}"=="True"    Run Keywords    Restart SAS Simulator
    ...    AND    Sleep    2 min
    Log Dictionary    ${NODE_CFG}
    Change Testline Configuration    ${config_id}    force_recommission=False
    ${status}    Run Keyword If    "${NOT_COMMISSIONED}"=="True"    Run Keyword And Return Status    Verify All Cells OnAir
    Run Keyword And Continue On Failure    Run Keyword If    "${NOT_COMMISSIONED}"=="True" and "${status}" == "False"
    ...    Reset BTS Until Onair    timeout=${ONAIR_TIME}
    ...    ELSE IF    "${NOT_COMMISSIONED}"=="False"    Wait For All Cells OnAir    timeout=${ONAIR_TIME}
    Check Multinode Without Unexpect Alarm
    Run keyword If    ${NEED_UPDATE}    Run Keywords    Update To Newer Package
    ...    AND    Set Suite Variable    ${NEED_UPDATE}    ${False}
    [Teardown]    Run Keyword If    "${KEYWORD STATUS}"=="PASS"    Run Keywords
    ...    Logging Multinode Stop    ${TEST_LOGS_DIR_PATH}/setup/
    ...    AND    Logging Multinode Start
    ...    AND    Logging Gnb Admin Start
    ...    AND    Get And Check Reset Counter For All BTS Node

Stability Testcase Basic Postcondition
    [Arguments]     ${pass_number}=${1}    ${run_number}=${1}
    Log    ${pass_number}
    Log    ${run_number}
    Logging Multinode Stop    test_status=${TEST STATUS}
    Stop and Fix
    Run Keyword And Ignore Error    Logging Gnb Admin Stop

Update To Newer Package
    ${status}    Run Keyword And Return Status    Variable Should Exist    ${NEW_BUILD}
    Return From Keyword IF    not ${status}
    ${package_type}    Get Variable Value    ${tl_config.PACKAGE_TYPE}    Normal
    Download SW Build    ${NEW_BUILD}    ${package_type}
    ${files}    OperatingSystem.List Files In Directory    ${SW_BUILDS_DIR_PATH}
    ${matched_file}    Get Matches   ${files}    ${NEW_BUILD}*
    ${swFile}    Set Variable    ${SW_BUILDS_DIR_PATH}${matched_file[0]}
    FOR    ${bts_id}    IN    @{BTS_LIST}
        Continue For Loop If    "${NEW_BUILD}"=="${NODE_CFG['${bts_id}']['software_active']}"
        Set To Dictionary    ${NODE_CFG['${bts_id}']}    active_file_path=${swFile}
        Set To Dictionary    ${NODE_CFG['${bts_id}']}    software_active=${NEW_BUILD}
        coam.Update Software    ${swFile}    timeout=4200    connection=${CASE_NAME}_${bts_id}
    END
    Sleep   1 min
    Verify HW State
    Wait For All Cells OnAir        timeout=${ONAIR_TIME}
    Check Multinode Without Unexpect Alarm
