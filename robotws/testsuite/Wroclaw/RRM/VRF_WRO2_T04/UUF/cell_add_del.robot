*** Settings ***
Documentation
...           UUF4ALL Site reset Test

Resource        taf/rfrl/uuf4all/uuf4all_test_cases.robot
Resource        taf/rfrl/uuf4all/uuf4all_keywords.robot
Resource        ../regression/regression_keywords.robot
Resource        ./resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common.py
Library         ute_syslog
Library         ./resources/delta.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/uuf_utils.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/tracing.py
Library         OperatingSystem
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T04/regression/global_variables.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/UUF/resources/cell_add_del.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cell_utilities.py
Variables      testsuite/Wroclaw/RRM/VRF_WRO2_T04/UUF/resources/variables.py

Force Tags      CA_VRF_WRO2

Suite Setup     Set Global Variables

Test Teardown    Add Scout Data Info To Testcase

Test Timeout     24h

*** Variables ***
${TEST_ITERATION2}=   ${VARIABLE['TEST_ITERATION2']}
${CRITICAL_FAULTS}   ${VARIABLE['critical_faults']}
${custom_alarms}     ${VARIABLE['custom_alarms']}
@{cutomers}=         TMO US
${delta_file}        testsuite/Wroclaw/RRM/VRF_WRO2_T04/UUF/resources/delta.json
${L3_call_keyword}   ${None}
${SERIAL_CONSOLE}=   ${False}
${report_comment}    RAN_PZ_WRO2_SG04


*** Test Cases ***
E2E_TL_Cell_Add_Cell_Del
    REMOVE AND ADD CELL
    ...    test_iteration=${TEST_ITERATION2}
    ...    customers_list=@{cutomers}
    ...    critical_faults=${CRITICAL_FAULTS}
    ...    custom_alarms=${custom_alarms}
    ...    report_comment=${report_comment}

*** Keywords ***
REMOVE AND ADD CELL
    [Arguments]  ${test_iteration}=1
    ...          ${custom_alarms}=@{EMPTY}
    ...          ${remote_vm_ip}=${None}
    ...          ${remote_mplane}=${None}
    ...          ${label}=${None}
    ...          ${hostname}=${None}
    ...          ${critical_faults}=@{EMPTY}
    ...          ${should_be_reported}=${False}
    ...          ${customers_list}=@{EMPTY}
    ...          ${use_remote_node}=${False}
    ...          ${disable_syslog_check}=${False}
    ...          ${user_suspicious_prints}=@{EMPTY}
    ...          ${report_comment}=${None}
    ...          ${qc_domain}=${None}
    ...          ${qc_project}=${None}
    ...          ${qc_id}=${None}
    uuf_rfrl_common_keywords.Common Test Setup  ${custom_alarms}  ${remote_vm_ip}  ${label}  ${hostname}
    ...  ${critical_faults}  ${should_be_reported}  ${customers_list}  ${remote_mplane}  ${use_remote_node}
    ...  ${disable_syslog_check}  ${user_suspicious_prints}  ${report_comment}  ${qc_domain}  ${qc_project}  ${qc_id}
    uuf_rfrl_common_keywords.Verify Test In Loop  ${test_iteration}
    ...  ${should_be_reported}  Remove And Add Random Cell Test
    [Teardown]  uuf_rfrl_common_keywords.Common Test Teardown

Remove And Add Random Cell Test
    [Arguments]    ${test_phase}
    Set Test Variable  ${CASE_TYPE}  NR_CELL_DEL
    ${random_nr_cell}     Select Random Nr Cell
    Set Test Variable    ${RANDOM_CELL}    ${random_nr_cell}
    Delete Random Cell    ${test_phase}
    Restore Cell  ${test_phase}
    [Teardown]    Run Keyword And Ignore Error    Add Cell    cell_id=${RANDOM_CELL}

Delete Random Cell
    [Arguments]    ${test_phase}=${EMPTY}
    Log To Console    Selected random cell for deletion: ${RANDOM_CELL}
    uuf_rfrl_common_keywords.Start Collecting Syslog    ${test_phase}/DEL_${RANDOM_CELL}
    uuf_rfrl_common_keywords.Get Blackbox File Before Test
    uuf_rfrl_common_keywords.Watch Alarms    ignore_gps=${True}
    Remove Cell    cell_id=${RANDOM_CELL}
    ${bts_state}  ${bts_error}=  Run Keyword And Ignore Error  uuf_rfrl_common_keywords.Verify BTS State  1200
    ...  ${test_phase} after cell delete
    uuf_rfrl_common_keywords.Get Blackbox File After Test
    ${logs_results}  ${logs_error}=  Run Keyword And Ignore Error  uuf_rfrl_common_keywords.Verify Logs
    ...   ${test_phase} after test  reset_check=${False}
    ${result}=  uuf_rfrl_common.Verify Iteration  ${test_phase}  ${bts_state}  ${logs_results}

    Run Keyword If  "${result}" == "False"  uuf_rfrl_common_keywords.Gather Snapshot  ${test_phase}/DEL_${RANDOM_CELL}
    uuf_rfrl_common.Check Stop Fix Trigger
    Run Keyword If  "${result}" == "False"  Fail  Del ${RANDOM_CELL} Failed - Loop ${i}
    Gather Snaphshot For First Passed Iteration      ${test_phase}/DEL_${RANDOM_CELL}
    [Teardown]  Run Keywords  uuf_rfrl_common_keywords.Stop Logging  AND
    ...         Run Keyword If  "${STOP_FIX}" != "False"  Fail  Stop And Fix Detected!

Restore Cell
    [Arguments]    ${test_phase}=${EMPTY}
    Log To Console    Restoring cell after deletion: ${RANDOM_CELL}
    Set Test Variable  ${CASE_TYPE}  NR_CELL_ADD
    uuf_rfrl_common_keywords.Start Collecting Syslog    ${test_phase}/ADD_${RANDOM_CELL}
    uuf_rfrl_common_keywords.Get Blackbox File Before Test
    uuf_rfrl_common_keywords.Watch Alarms    ignore_gps=${True}
    Add Cell    cell_id=${RANDOM_CELL}
    ${bts_state}  ${bts_error}=  Run Keyword And Ignore Error  uuf_rfrl_common_keywords.Verify BTS State  1200
    ...  ${test_phase} after cell delete
    uuf_rfrl_common_keywords.Get Blackbox File After Test
    ${logs_results}  ${logs_error}=  Run Keyword And Ignore Error  uuf_rfrl_common_keywords.Verify Logs
    ...   ${test_phase} after test  reset_check=${False}
    ${result}=  uuf_rfrl_common.Verify Iteration  ${test_phase}  ${bts_state}  ${logs_results}


    Run Keyword If  "${result}" == "False"  uuf_rfrl_common_keywords.Gather Snapshot  ${test_phase}/ADD_${RANDOM_CELL}
    uuf_rfrl_common.Check Stop Fix Trigger
    Run Keyword If  "${result}" == "False"  Fail  Add ${RANDOM_CELL} Failed - Loop ${i}
    Gather Snaphshot For First Passed Iteration      ${test_phase}/ADD_${RANDOM_CELL}
    [Teardown]  Run Keywords  uuf_rfrl_common_keywords.Stop Logging  AND
    ...         Run Keyword If  "${STOP_FIX}" != "False"  Fail  Stop And Fix Detected!
