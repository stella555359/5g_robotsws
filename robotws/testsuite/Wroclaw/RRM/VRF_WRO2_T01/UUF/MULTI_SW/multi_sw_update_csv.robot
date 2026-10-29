*** Settings ***
Documentation
...   Multi Update Test based on CSV4ALL copied from VRF_WRO2_T04
...   robot -v tester_name:<user> -v CUSTOM_END_DATE:DD-MM-YYYY_HH:MM -b <name_logs>.log -L TRACE -V "/home/ute/testline_configuration/<TL_name>/"
...   -t *MULTI* testsuite/Wroclaw/RRM/VRF_WRO2_T01/UUF/MULTI_SW/multi_sw_update_csv.robot
...   i.e. -v CUSTOM_END_DATE:27-01-2026_11:00  or 03-12-2025_07:00
...   if no CUSTOM_END_DATE declared time to next day to 6:00 Warsaw time.
...   robot -v tester_name:mozola -v CUSTOM_END_DATE:12-12-2025_15:00 -b mozi_debug.log -L TRACE -V "/home/ute/testline_configuration/7_16_UTE5GSA5/"
...   -t *MULTI* testsuite/Wroclaw/RRM/VRF_WRO2_T01/UUF/MULTI_SW/multi_sw_update_csv.robot

...  Test Author:     Tomasz Godlewski
...  Contact:         tomasz.1.godlewski@nokia.com, tomasz.mozola@nokia.com

Library         taf/rfrl/csv4all/CSV4AllTestCases.py
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/UUF/resources/keywords.resource
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/UUF/resources/keywords.py
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T01/UUF/resources/multi_sw_uuf_variables.py      # VRF_WRO2_T01 vars
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/regression/regression_keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/ute_report.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common.py
Library         ute_syslog
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/uuf_utils.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/tracing.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/UUF/resources/builds.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/UUF/resources/files.py
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T04/UUF/resources/notifications.py
Library         OperatingSystem
Library         taf.rfrl.csv4all.resources.utilities.utilities
# Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T04/regression/global_variables.py
# Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/UUF/multi_update_csv.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/Suite_repository.robot
# Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/UUF/resources/multi_sw_keywords.robot


Force Tags      CA_VRF_WRO2


Test Setup     Run keywords
...             Set Tester Name                           AND
...             check_and_update_flag


Test Timeout    100h


*** Variables ***
${CRITICAL_FAULTS}              ${VARIABLE_default['critical_faults']}
${custom_alarms}                ${VARIABLE_default['custom_alarms']}
@{customers}=                   TMO US
${SERIAL_CONSOLE}=              ${False}
${STOP_TEST_AFTER_FAIL}         ${False}
${USE_DCAP}                     ${False}
${RESTORE_TARGET_SW}            ${True}
${USE_BUILDS_STORAGE}           ${False}
${DOWNLOAD_PATH}                ${None}
${CALCULATE_KPI}                ${True}
${SHOULD_BE_REPORTED}=          ${True}
${MUMIN_CONFIG_FILE}=           ${None}
${rep_comment}                 VRF_WRO2_T01_01
@{ADDITIONAL_SW_OPERATIONS}    RESET BBMOD    RESET SITE    RESET RU
&{PERFORMED_OPERATIONS}
${NOTIFICATIONS}               ${TRUE}
${TEST_RESULT}                 OK
${NOTIFICATION_LIMIT}          ${3}
${NOTIF_COUNTER}               ${0}
${RP_CA}                       VRF_RRM
${RP_LOCATION}                 VRF_WRO2
${RP_ORGANIZATION}             VRF_WRO2_T01
${QC_DOMAIN}                   ${None}
${LABEL}                       VRF_WRO2_T01_CSV4ALL
${TEST_QC_ID}                  ${None}
${QC_PROJECT}                  ${None}
${SOURCE_SW}                   ${EMPTY}
${TARGET_SW}                   ${EMPTY}
@{IGNORED_PRINTS}              is not defined in SysinfoQuota.xml. Please contact the owner

&{NODE1}                    testline_object=${tl.gnbs[0]}
...                         node_vm=${tl.test_pc.default_ssh_connection_details.addr}
...                         node_alias=NR
...                         source_sw=${SOURCE_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${custom_alarms}
...                         critical_alarms=${CRITICAL_FAULTS}
...                         syslog_ignored_prints=${IGNORED_PRINTS}

@{NODES}                    ${NODE1}

*** Test Cases ***
MULTI SW UPDATE
    ${START_SW}=    uuf_utils.Get Current Sw
    ${START_DATE}    Get Current Date    result_format=%d-%m-%Y %H:%M
    ${END_DATE}    Set End Date    ${START_DATE}

    Set Suite Variable    @{sw_operations}    @{ADDITIONAL_SW_OPERATIONS}
    Log To Console    \nStart date: ${START_DATE}
    Log To Console    \nStart SW: ${START_SW}

#    ${END_DATE}    Set Suite Variable   dd-mm-yyyy hh:mm
    ${CUSTOM_END_DATE}=    Parse Custom Date From Cmd
    ${END_DATE}    Set Variable If    '${CUSTOM_END_DATE}' != 'None'    ${CUSTOM_END_DATE}    ${END_DATE}
    Log To console    \nEnd date: ${END_DATE}

    FOR    ${n}    IN RANGE    1    1000
        Set Suite Variable    ${OPERATION_STATUS}    None
        Set Test Variable    ${n}    ${n}
        Run Keyword If    ${sw_operations} == @{EMPTY}    Refill Sw Operations
        ${5G_SOURCE_SW}=  uuf_utils.Get Current SW
        Set To Dictionary    ${NODE1}    source_sw    ${5G_SOURCE_SW}

        Test Logger    \n\n\n*** [MULTI] Iteration: ${n} ***    hyperlink=${TRUE}
        ${current_date}    Get Current Date    result_format=%d-%m-%Y %H:%M
        Log To Console  Current date: ${current_date}
        ${is_time_finished}    Is Time Finished    ${current_date}    ${END_DATE}
        Run Keyword If    ${is_time_finished}    Run Keywords
        ...    Log    Time's up!!  console=${TRUE}    AND
        ...    Set Suite Variable    ${OPERATION_STATUS}    SuiteFinished
        Exit For Loop If   ${is_time_finished}
        Log    Checking if newer build is available..    console=True
        ${5G_TARGET_SW}    verify_if_newer_build_appeared
        Run Keyword If    '${5G_TARGET_SW}' == '${FALSE}'
        ...    Set Global Variable    ${5G_TARGET_SW}    ${5G_SOURCE_SW}
        ...    ELSE    Set Global Variable    ${5G_TARGET_SW}    ${5G_TARGET_SW}
        Set To Dictionary    ${NODE1}    target_sw    ${5G_TARGET_SW}
        Run Keyword If   '${5G_TARGET_SW}' != '${5G_SOURCE_SW}'
        ...    UPGRADE BTS    ${5G_TARGET_SW}
        ...    ELSE    Select And Run Random Operation
        Set To Dictionary    ${PERFORMED_OPERATIONS}    ${n}    ${CURRENT_OPERATION}
        Run Keyword If    "${OPERATION_STATUS}"=="False"    Move Logs To Destination
        ...    destination_directory=${OUTPUT_DIR}
        ...    current_iteration=${n}
        ...    current_operation=${CURRENT_OPERATION}
        Run Keyword If    "${OPERATION_STATUS}"=="False"    Run Keywords
        ...    Test Logger    *** [MULTI] Iteration: ${n} ---FAILED---! ***\n\n\n    hyperlink=${TRUE}    AND
        ...    Run Keyword And Ignore Error    notify_chat_about_fail
        ...    operation=${CURRENT_OPERATION}   iteration=${n}    notif_counter=${NOTIF_COUNTER}    AND
        ...    Set Suite Variable    ${TEST_RESULT}    NOK
        Run Keyword If    "${TEST_RESULT}"=="OK"    Cleanup Pcap Files If Iteration Passed    ${n}
        Clean Builds
    END
    [Teardown]    Run Keywords
    ...  Prepare Summary    AND
    ...  Run Keyword If    "${OPERATION_STATUS}"=="None"    Run Keyword And Ignore Error
    # ...  notify_chat_about_fail  operation=${CURRENT_OPERATION}  iteration=last    AND
    ...  Run keyword if  "${TEST_RESULT}"=="NOK" or "${OPERATION_STATUS}"=="None"  FAIL  At least one iteration failed!


*** Keywords ***
Select And Run Random Operation
    Run Keyword If    ${sw_operations} == @{EMPTY}    Refill Sw Operations
    ${random_operation}    Evaluate    random.choice(${sw_operations})    random
    Log  Selected operation: ${random_operation}
    Remove Values From List    ${sw_operations}    ${random_operation}
    Log To Console    Remaining sw operations: ${sw_operations}
    Set Suite Variable    ${CURRENT_OPERATION}    ${random_operation}
    ${OPERATION_STATUS}    Run Keyword And Return Status    ${random_operation}
    Set Suite Variable    ${OPERATION_STATUS}    ${OPERATION_STATUS}

Refill Sw Operations
    Set Suite Variable    @{sw_operations}    @{ADDITIONAL_SW_OPERATIONS}
    Log To Console  Current sw operations: ${sw_operations}

UPGRADE BTS
    [Arguments]    ${target_sw}
    Set Suite Variable    ${CURRENT_OPERATION}    UPGRADE BTS
    Run Keyword And Continue On Failure    Start Continuous Tcpdump    iter_var=n
    Log To Console    ${NODES}
    ${OPERATION_STATUS}    Run Keyword And Return Status    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  sw_build=${target_sw}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${customers}
    ...  report_comment=${rep_comment}
    ...  topology=${LABEL}
    ...  use_external_storage=${USE_BUILDS_STORAGE}
    ...  download_path=${DOWNLOAD_PATH}
    ...  restore_to_target_sw=${RESTORE_TARGET_SW}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}
    ...  l3_call_method=${None}

    Set Suite Variable    ${OPERATION_STATUS}    ${OPERATION_STATUS}
    [Teardown]    Stop Continuous Tcpdump

RESET BBMOD
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${customers}
    ...  report_comment=${rep_comment}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

RESET SITE
    Run Keyword And Continue On Failure    Start Continuous Tcpdump    iter_var=n
    E2E TL SITE RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${customers}
    ...  report_comment=${rep_comment}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

    [Teardown]    Stop Continuous Tcpdump

RESET RU
    E2E TL RU RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=1
    ...  report=${SHOULD_BE_REPORTED}
    ...  calculate_kpi=${CALCULATE_KPI}
    ...  use_dcap=${USE_DCAP}
    ...  qc_domain=${QC_DOMAIN}
    ...  qc_id=${TEST_QC_ID}
    ...  qc_project=${QC_PROJECT}
    ...  customers_list=${customers}
    ...  report_comment=${rep_comment}
    ...  topology=${LABEL}
    ...  stop_test_after_fail=${STOP_TEST_AFTER_FAIL}

Prepare Summary
    Log Dictionary   ${PERFORMED_OPERATIONS}
    ${operations_as_list}    Get Dictionary Values    ${PERFORMED_OPERATIONS}
    ${operations}=    Copy List    ${ADDITIONAL_SW_OPERATIONS}
    Append To List    ${operations}    UPGRADE BTS

    &{summary}    Create Dictionary
    FOR    ${element}    IN    @{operations}
        ${num}    Count Values In List    ${operations_as_list}    ${element}
        Set To Dictionary    ${summary}    ${element}    ${num}
    END
    Log Dictionary    ${summary}

Parse Custom Date From Cmd
    ${CUSTOM_END_DATE}    Get Variable Value    ${CUSTOM_END_DATE}    ${NONE}
    ${CUSTOM_END_DATE}    Run Keyword If    '${CUSTOM_END_DATE}' != 'None'    Replace String    ${CUSTOM_END_DATE}    _    ${SPACE}
    [Return]    ${CUSTOM_END_DATE}
