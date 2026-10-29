*** Settings ***
Resource    ./5GC001113_A_Variables.robot
Resource    ./../../../5GC001596_D/Resources/5GC001596_D_Keywords.robot

Documentation
...   author: Liu Zheng
...   contact: zheng.4.liu@nokia-sbell.com
...   squad group: MMW_SG1
...   Feature 5GC001113_A in 5G21A program


*** Variables ***


*** Keywords ***
Suite Setup for 1113
    [Arguments]    ${prepare_ue}=${False}
    Suite common setup preparation    is_pdl_checking_needed=${False}      enb_default_scf_file=${ENB_SCF_DEFAULT_FILE_PATH}
    ...    prepare_ue=${prepare_ue}    enb_index=${ENB_INDEX}
    Import variables    ${CURDIR}/../../TestData/variables.py
    Wait Until Keyword Succeeds    1min    3s    Connect to gnb coam via ssl
    ${Active_SW_version}    Get Active SW Version
    set suite variable      ${Active_SW_version}
    Set suite variable      ${SAVE LOG DIRECTORY}    ${SUITE_LOG_PATH}
    ${scf_path}    Download SCF Download Via Rest Api    scf_dir_path=${SAVE LOG DIRECTORY}
    ${mrbtsID}    ${nrbtsID}   Get mrbtsID and nrbtsID via SCF for gNB    scf_path=${scf_path}
    log to console  MRBTS_ID:${mrbtsID}, NRBTS_ID:${nrbtsID}
    set suite variable  ${mrbtsID}
    set suite variable  ${nrbtsID}
    Get the ru index list and cell index list and cell group index list and set to suite variable

Suite Teardown for 1113
    Common suite recovery    is_log_required=${True}
    Run Keyword And Ignore Error    process.Terminate All Processes    kill=True

Test Setup for 1113
    [Arguments]    ${if_create_alias_needed}=${False}    ${if_create_ru_alias_needed}=${False}    ${is_log_required}=${True}
    Common case setup    is_alias_created=${if_create_alias_needed}    if_create_ru_alias_needed=${if_create_ru_alias_needed}
    ...    is_log_required=${is_log_required}   enb_index=${ENB_INDEX}
    Set Test Variable    ${SAVE LOG DIRECTORY}    ${TS_CASE_LOG_PATH}
    Run Keyword And Ignore Error    selenium_coam.close_browser

Test Teardown for 1113
    [Arguments]    ${is_log_required}=${True}    ${ue_index}=${0}    ${detach_ue}=${False}
    ...    ${is_onair_check}=${False}    ${onair_timeout}=${DEFAULT_ONAIR_TIMEOUT}    ${is_close_connection}=${True}
    ...    ${operation}=${None}    ${ru_index}=${1}    ${cell_index}=${1}    ${cell_group_index}=${0}
    Connect to gnb coam via ssl
    ${ru_status}   run keyword and ignore error   COAM Check GNB RU status
    log to console  RU status: ${ru_status}
    ${cell_status}    Run Keyword And Return Status    Verify all cells should be onair
    should be true    ${cell_status}
    ${alarm_status}    Run Keyword And Return Status    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    should be true    ${alarm_status}
    ${history_alarm_status}    Run Keyword And Return Status    Unexpect History Alarm Should Not Exist
    ...    allowed_faults=${ALLOWED_HISTORY_FAULT}
    Common case teardown    is_log_required=${is_log_required}    ue_index=${ue_index}    detach_ue=${detach_ue}
    ...    is_onair_check=${is_onair_check}    onair_timeout=${onair_timeout}
    ...    is_close_connection=${is_close_connection}
    Recovery env if case failed with operations    operation=${operation}    ru_index=${ru_index}    cell_index=${cell_index}
    ...    cell_group_index=${cell_group_index}
    run keyword if    ${is_close_connection}==${False}    run keyword and ignore error    Close all connection

Modify parameters within RU range and 1900 fault not report
    [Arguments]    ${parameters_to_update_via_api}     ${timeout}=${TIMEOUT_MODIFY_PARA}
    ...    ${connection}=${GNB_COAM_ALIAS}    ${ru_index}=1
    # Step 1: Modify nrarfcn or pmax (within RU range), and bts is triggered reset.
    ${update_status}    COAM Update several parameters via rest api
    ...     parameters_to_update_via_api=${parameters_to_update_via_api}    timeout=${timeout}
    Run keyword and continue on failure    should contain Any    ${update_status}    PASS    RESET_PASS
    # Step 2: Check 1900 fault should be cleared.
    Wait until cluster is on cell on air status    timeout=${RECOVERY_TIMEOUT}    enb_index=${ENB_INDEX}
    coam_siso_common.Expect Fault Should Absent    faultId=1900    connection=${GNB_COAM_ALIAS}
